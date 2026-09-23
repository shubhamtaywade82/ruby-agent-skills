# Routing Campaign Evidence Verification

Protocol version: 1

`bin/routing-campaign-evidence-verify` validates a completed public routing campaign evidence package independently of the model runtime.

It verifies campaign identity, public case/repetition/run cardinality, intake state, clean repository provenance, provider/model metadata, required contract artifacts, runtime preflight, exact raw-run artifact cardinality, and artifact digest/size metadata.

Use `--check-files` to recalculate the recorded SHA-256 and byte-size values from the artifact paths.

Campaign evidence must pass this verifier before archival.
