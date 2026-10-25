# Provider Adapters and Budgets

## The adapter boundary

One object in the application talks to a provider; everything else talks to that object. The adapter is where provider choice, auth, retries, telemetry, and budgets live, and it is the seam that makes the system testable and providers swappable:

```ruby
class LLM::Adapter
  def initialize(client:, config:)
    @client = client          # RubyLLM, Faraday-backed client, or a test double
    @config = config          # model, endpoint, version — from configuration, not code
  end

  def chat(messages:, feature:, **options)
    LLM::Provider.new(client: @client, config: @config)
                  .complete(prompt: Prompt.new(messages, feature: feature), **options)
  end
end
```

The gem question (RubyLLM vs hand-rolled Faraday) is a dependency decision, not an architecture one: RubyLLM unifies OpenAI/Anthropic/Ollama-ish providers behind one chat API with tool support, and is the right default when its abstractions fit; hand-rolled Faraday is appropriate when the needed contract is thin or the gem's retry/timeout defaults disagree with your budget. Either way the application sees only `LLM::Adapter`, and a provider swap is a configuration change verified by the same contract tests.

Anti-boundary smells: SDK types (`RubyLLM::Chat`, `Faraday::Response`) leaking past the adapter; six services each constructing their own client; model names hardcoded at call sites; tests that stub HTTP internals instead of the adapter.

## Timeouts and retries

Every call is bounded in time, explicitly, at three layers that must agree:

| Layer | Bound | Notes |
|---|---|---|
| HTTP open timeout | ~2-5s | connection establishment must fail fast |
| HTTP read timeout | feature's latency budget | a chat feature may allow 30s; a request-path feature should not call an LLM at all |
| job/queue timeout | > read timeout | background work waits, but not forever |

Retry policy distinguishes failure classes:

| Failure | Retry? |
|---|---|
| connection refused / reset before response | yes, with backoff — the request likely was not processed (still re-check budget) |
| 429 rate limited | yes, honoring `Retry-After`, within the feature's patience |
| 5xx | bounded retry (1) at most — the provider may have processed and billed the first attempt |
| timeout | no automatic retry on the request path; retry only in idempotent background work, and always inside the cost budget |
| 4xx (bad request, context overflow) | never — fix the request |

Token-spending caution: a retried call whose first attempt may have partially processed spends budget twice; the budget meter (below) must count attempts, not successes.

```ruby
def complete(prompt:, budget:)
  raise BudgetExhausted if LLM.cost_meter.exhausted?(prompt.feature)

  with_retries(safe_classes: SAFE_TO_RETRY, max: 2, backoff: :exponential) do
    response = @client.chat(messages: prompt.messages, model: @config.model, timeout: READ_TIMEOUT)
    LLM.cost_meter.record(feature: prompt.feature, tokens: response.usage)
    response
  end
end
```

## Token and cost budgets

Budgets are per-request, per-feature, and per-period, enforced *before* the call where possible:

- **per request**: `max_tokens` set from the feature's need, not the provider's maximum; input trimmed or chunked to fit the model's window with margin;
- **per feature/period**: a cost meter recording tokens and (with per-model pricing tables) money, checked before expensive calls — "daily summarization" has a daily number, "per-user assistant" has a per-user number;
- **anomaly detection**: a feature whose average cost doubles is an alert, not a surprise invoice — the meter's per-feature series makes that observable;
- local models are not free: GPU memory, queue depth behind one Ollama instance, and seconds-per-token are the budgets, and concurrent requests queue invisibly unless the adapter exposes queue time.

## Model/version compatibility

Model identifiers are dependencies, and unpinned dependencies drift:

- pin model (and provider API) versions in configuration; an upgrade is a behavior change that needs evaluation of the affected features before it ships;
- record the resolved model version on every call's telemetry — a "why did quality change?" investigation starts by correlating with version changes;
- local Ollama models pin their tag/version too (`llama3.1:8b-instruct-q4`), and the adapter verifies the served model matches configuration at startup rather than failing mysteriously mid-session;
- capability differences (context window, tool-calling support, JSON mode) are adapter-level feature flags, not assumptions sprinkled through call sites: the adapter exposes what the configured model supports, and features degrade when it does not.

## Provider fakes and contract tests

The adapter boundary earns its keep in tests:

```ruby
class FakeChatClient
  def initialize(script = {})
    @script = script    # {input_fingerprint => response} or a sequence
  end

  def chat(messages:, model:, timeout:, **)
    response_for(messages) # deterministic: same messages, same scripted reply
  end
end

class LLM::AdapterTest < ActiveSupport::TestCase
  test "unavailable provider raises LLM::Unavailable after bounded retries" do
    client = FakeChatClient.new
    client.script_connection_refused!

    assert_raises(LLM::Provider::Unavailable) do
      LLM::Adapter.new(client: client, config: config).chat(messages:, feature: "summarize")
    end
  end
end
```

Contract tests assert the adapter's promises: bounded time, retry classes, usage recording, schema validation, and the exact exceptions the application must handle — so a provider swap, gem upgrade, or version change is verified against the same promises. Live provider calls never run in CI; recorded fixtures or fakes do.
