# Routing Campaign Evidence Verification

Protocol version: 1

`bin/routing-campaign-evidence-verify` validates a completed public routing campaign evidence package independently of the model runtime.

It verifies campaign identity, public case/repetition/run cardinality, intake state, clean repository provenance, provider/model metadata, required contract artifacts, runtime preflight, exact raw-run artifact cardinality, artifact digest/size metadata, and—when `--check-files` is supplied—semantic analysis provenance by replaying `bin/routing-analyze` against the captured campaign.

Use `--check-files` to recalculate the recorded SHA-256 and byte-size values from the artifact paths.

Campaign evidence must pass this verifier before archival. The verifier also requires the evidence-level analysis to equal the preserved report summary and the evidence-level campaign metrics to equal the campaign artifact metrics.
