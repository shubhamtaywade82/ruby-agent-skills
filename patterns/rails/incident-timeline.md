---
name: incident-timeline
description: Construct factual incident timelines from durable telemetry, deploy, control-plane, and operator-action timestamps.
family: rails
---

# Incident Timeline

## Problem
Post-incident narratives become unreliable when timelines are reconstructed from memory rather than timestamped evidence.

## Use when
- documenting incidents;
- correlating onset with changes;
- reviewing mitigation and recovery.

## Do not use when
- there is no operational event sequence to reconstruct;
- writing ordinary feature documentation.

## Repository inspection
Inspect log timestamps, telemetry timestamps, deployment history, feature-flag audit logs, queue/message events, and operator action records.

## Implementation procedure
1. Establish first known symptom. 2. Add alerts and acknowledgement. 3. Mark relevant changes. 4. Record scope changes. 5. Record diagnostic discoveries. 6. Record mitigation. 7. Record recovery and monitoring. 8. Separate observed facts from hypotheses.

## Failure modes
- using memory as authoritative;
- mixing local and UTC timestamps without labeling;
- rewriting hypotheses as facts;
- omitting failed mitigations.

## Testing
Timeline tooling or templates should preserve timestamp ordering, source references, and explicit fact-versus-hypothesis labels.

## Review checklist
- [ ] timestamp source known; - [ ] changes marked; - [ ] failed actions preserved; - [ ] facts separated from hypotheses; - [ ] recovery recorded.

## Related skills
rails-incident-engineering, rails-observability, rails-production-runtime