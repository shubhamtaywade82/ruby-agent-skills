# Operations and Degradation

## LLM observability

An LLM call is an external dependency with a cost, and it is observed like one — plus the model-specific dimensions:

| Dimension | What it answers |
|---|---|
| latency (p50/p95, by feature) | does this feature fit its latency budget? |
| failure class | unavailable vs invalid-output vs budget-exhausted vs refused |
| tokens in/out, cost (by feature, by day) | what does this feature spend? is spend anomalous? |
| retry count per call | is the provider flaky, or is the request pathological? |
| invalid-output rate | is the schema/prompt drifting out of the model's competence? |
| refusal rate | is the content policy rejecting your legitimate traffic? |
| model/version | what changed when behavior changed? |

Logged per call — identifiers and counts, never prompt bodies:

```ruby
ActiveSupport::Notifications.instrument("llm.call",
  feature: prompt.feature, model: @config.model, duration_ms: ms,
  input_tokens: usage.input, output_tokens: usage.output,
  retries: attempt, outcome: outcome,       # ok | unavailable | invalid_output | budget_exhausted
  request_id: request_id
end
```

Prompt-content logging is a privacy decision made explicitly: if debugging requires samples, they are truncated, redacted of secrets/PII, opt-in per feature, and retained briefly — the default is the metadata above.

## Graceful degradation

Every LLM feature answers, in design, "what happens when the model is unavailable/slow/expensive?" — and the answers compose:

| Strategy | Fits | Shape |
|---|---|---|
| cached result | content where staleness is acceptable (summaries, classifications) | serve last-good with an "older data" marker, refresh in background |
| rule-based fallback | features with a simpler deterministic approximation | classifier falls back to keyword rules; drafting falls back to a template |
| queue-and-notify | user-facing generation that can be async | enqueue; deliver when done; never block the request on a model |
| feature hides | optional assistance | the button disappears; core flows untouched |
| explicit unavailability | features that cannot fall back | a clear "could not generate" result, not a stack trace or silence |

The design test: turn the provider off (the fake raises `Unavailable`), run the suite, and the application's core paths stay green. If checkout, search, or the risk pipeline turns red with the LLM down, the dependency is structural, not assistive — that is the finding to fix.

```ruby
class SummarizationService
  def summarize(document)
    Rails.cache.fetch(cache_key(document), expires_in: 1.hour) do
      provider.complete(prompt: prompt_for(document), schema: SUMMARY_SCHEMA).result
    end
  rescue LLM::Provider::Unavailable, LLM::InvalidSchema
    cached = Rails.cache.read(cache_key(document))
    return cached&.merge(stale: true) if cached

    raise SummarizationUnavailable        # the caller decides; the caller is not the model
  end
end
```

## LLMs in deterministic systems

The composition rule, restated as the deployment question: **where does the model sit relative to the deterministic path?**

- **before the guards (drafting)**: model output produces *proposals* — intents, drafts, classifications — which then enter the normal deterministic path (schema validation, authorization, risk gates) unchanged. Safe; this is the recommended position.
- **beside the path (advisory)**: model output annotates, explains, or ranks, but nothing consequential consumes it directly. Safe.
- **in the path (decision-making)**: the deterministic result *depends* on the model's output (a gate that "consults" the model, an authorization the model informs). Unsafe at any latency and any accuracy — reliability of the guarantee silently becomes the reliability of an external provider. Redesign: the model drafts, the deterministic rule decides.

For consequential domains (trading, payments, medical, access control) the audit question is sharp: trace every consumer of model output. If any consumer is a guard, an authorizer, or a numeric input to a safety calculation, the model is in the path — move it out. The trading-specific corollary: an LLM can draft an order intent, and the intent then faces the identical risk gates, live-mode gates, and state machine as any human- or rule-authored intent; blocked is blocked, whoever drafted.

## Backgrounding and caching

Two operational levers that keep LLM cost and latency off the request path:

- **background jobs** for generation that does not need to be synchronous: the request enqueues, the UI receives the result by polling or push, and the job's retry policy is the adapter's bounded-retry discipline with idempotent work (a duplicate summary run wastes budget; a draft email sent twice is worse — job identity and deduplication follow the messaging discipline the rest of the application uses);
- **caching with purpose-bounded keys**: identical inputs (document digest + prompt version + model version) reuse results; the cache key includes the *prompt version* so a prompt change does not serve stale behavior, and TTLs reflect the content's staleness tolerance.

Batching closes the cost loop for bulk work: classification over 10,000 items goes through a batched/async pipeline with per-feature budget checkpoints — not 10,000 synchronous requests from a rake task someone forgot about.
