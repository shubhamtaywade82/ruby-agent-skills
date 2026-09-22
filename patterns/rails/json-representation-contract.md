---
name: json-representation-contract
description: JSON Representation Contract
family: rails
---
# JSON Representation Contract

## Problem
as_json and to_json are confused, causing double encoding or inconsistent response shapes.

## Use when
Changing model JSON representation or response encoding.

## Do not use when
The API boundary already owns a dedicated serializer with no model JSON behavior.

## Repository inspection
Inspect controller rendering, serializer classes, as_json, to_json, and content types.

## Implementation procedure
Keep as_json as a representation contract and JSON encoding at the transport edge; avoid pre-encoding representations.

## Failure modes
Double-encoded JSON, string/object mismatches, inconsistent content types.

## Testing
Test representation separately from the final HTTP JSON response.

## Review checklist
[ ] representation object [ ] encoding edge [ ] content type [ ] exact JSON

## Related skills
rails-serialization-globalid-engineering, rails-action-controller