---
name: login-abuse-controls
description: Design bounded defenses against credential stuffing, brute force, account enumeration, reset abuse, and authentication endpoint overload.
family: rails
---

# Login Abuse Controls

## Problem

Authentication endpoints are public and computationally expensive, making them targets for credential attacks and denial of service.

## Use when

Adding login throttling, lockout, CAPTCHA/challenges, anomaly detection, reset throttling, or abuse response.

## Do not use when

Only implementing a local form validation rule unrelated to attack volume.

## Repository inspection

Inspect authentication endpoints, identity normalization, rate-limit store, failure telemetry, reverse proxy/WAF controls, reset endpoints, and existing security controls.

## Implementation procedure

1. Identify threats and attacker-controlled dimensions.
2. Define failure semantics.
3. Prevent account enumeration.
4. Add bounded throttling by appropriate dimensions.
5. Add progressive challenge/lock behavior if required.
6. Define reset/recovery throttles.
7. Ensure controls do not become permanent denial-of-service primitives.
8. Instrument bounded abuse signals.
9. Test threshold and recovery behavior.

## Failure modes

- one global IP limit
- permanent account lockout
- different responses for existing/non-existing users
- reset endpoint unrestricted
- high-cardinality attacker input in metrics

## Testing

Test repeated failures, threshold behavior, safe recovery, enumeration resistance, and successful login after throttle expiration.

## Review checklist

- [ ] threat model explicit
- [ ] throttles bounded
- [ ] enumeration minimized
- [ ] recovery path safe
- [ ] telemetry bounded

## Related skills

- rails-authentication
- rails-security
- rails-reliability-engineering
- rails-observability

