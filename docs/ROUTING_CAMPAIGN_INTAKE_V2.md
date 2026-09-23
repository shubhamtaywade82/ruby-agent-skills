# Routing Campaign Intake v2

Protocol version: 1

## Preflight verification

`bin/routing-campaign-preflight-verify` validates a captured runtime preflight without requiring access to Ollama. It verifies the public campaign identity, case/repetition math, model identity fields, and SHA-256 identities for the repository routing contract.

## External campaign import

`bin/routing-campaign-import` is the single intake command for a completed external runtime campaign.

It requires:

- `campaign.json`
- `preflight.json`

It then:

1. verifies the campaign against the public routing contract;
2. verifies preflight against the repository contract;
3. proves the campaign and preflight describe the same campaign/model/run count;
4. packages the raw results and contract artifacts as campaign evidence;
5. optionally creates the immutable routing evidence archive.

No scoring adjustment or result repair is performed.

## Real campaign handoff

On a machine with Ollama access:

```bash
ruby bin/routing-campaign-handoff --model <MODEL>
cd /path/to/ruby-agent-skills
./routing-handoff/run-campaign.sh
```

After completion, import the resulting campaign:

```bash
ruby bin/routing-campaign-import ./routing-campaign-output \
  --archive ./routing-archives
```

The public campaign remains **14 cases × 3 repetitions = 42 executions** unless an explicit repetition override is part of the experiment contract.
