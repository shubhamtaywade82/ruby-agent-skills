# Routing Campaign Analysis

`bin/routing-analyze` is the post-run analysis boundary for the public routing campaign.

## Inputs

The command consumes the completed `campaign.json` produced by `bin/routing-eval`. The campaign contains the public case contract, repeated observed decisions, agent metadata, and routing provenance. The analyzer does not call the model and does not create missing runs.

    ruby bin/routing-analyze ./routing-campaign-output/campaign.json \
      --output ./routing-campaign-output/analysis.json

## Validation

Before reporting metrics, the analyzer checks:

- recorded case count versus `routing_case_count`;
- requested repetitions are valid;
- every expected primary skill is registered;
- every completed run contains expected and observed routing data;
- observed primary and secondary skills are registered;
- the primary skill is not duplicated as a secondary skill;
- the campaign's recorded `completed_runs` matches the runs actually observed;
- a campaign marked complete contains the full requested run count.

An inconsistent campaign exits non-zero.

## Metrics

`primary_accuracy` is the fraction of completed runs whose observed primary skill equals the expected primary skill.

`secondary_recall` is the fraction of expected secondary-skill selections recovered in the observed secondary-skill list. Cases with no expected secondary skills contribute a recall of `1.0`.

`average_unexpected_secondary_count` measures the average number of observed secondary skills that were not expected for the case.

`primary_confusions` aggregates expected-primary to observed-primary mismatches and retains the affected case IDs.

`modal_primary_skill` is the most frequently observed primary skill for a case. `repetition_stability` is the modal-primary frequency divided by the number of completed repetitions. An unstable case is one where more than one primary skill was observed.

## Evidence interpretation

The report distinguishes repository-computed measurements from the campaign's completion flag. It never treats a missing or invalid run as a successful decision and never substitutes a synthetic observation.

Use the report as the analysis input to routing-remediation comparison. Remediation should be driven by observed confusion/stability evidence and then validated with a controlled baseline/candidate experiment.
