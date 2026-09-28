# Validation lifecycle, built-in validators, and conditional validation

Reference for the `rails-validations` skill. Load it on demand when a change adds or alters validators, when validation runs, or optional/conditional rules. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Validation lifecycle

Establish exactly which entry points run validation.

Rails normally runs validations before common persistence methods such as create, save, and update, while several direct/bulk write APIs bypass normal validation. save(validate: false) explicitly skips validation.

For each changed rule, answer:

- Is it always active?
- Is it create-only or update-only?
- Is a custom validation context used?
- Is it conditional?
- Can the write path bypass it?
- Does association validation invoke additional validators?
- Does persistence depend on database constraints after validation?

Never infer validation coverage from a model declaration alone.

## Built-in validator selection

Prefer the narrowest built-in validator that expresses the contract.

Common categories include absence, acceptance, confirmation, comparison, format, inclusion/exclusion, length, numericality, presence, uniqueness, validates_associated, validates_each, and validates_with.

Validator options include on, except_on, if, unless, allow_nil, allow_blank, strict, and message.

Do not stack overlapping validators merely for defensive appearance. Make the contract readable and test boundary cases.

### Presence and absence

Be explicit about nil, blank strings, false, empty collections, and absent associations.

Boolean requiredness should use boolean-appropriate inclusion/exclusion rules rather than presence, because false is blank in Rails.

For association presence, validate the association when the domain contract is about the related object rather than only its foreign-key column. Coordinate with rails-associations.

### Format

Use anchored formats when the entire string is the contract. Prefer absolute string anchors where appropriate. Keep format validation separate from normalization and parsing.

### Numericality and comparison

Define units, bounds, inclusivity, nilability, and coercion expectations. A successfully cast number is not automatically valid domain state.

## Optionality and conditional validation

Treat these as different decisions:

- allow_nil: skip when nil;
- allow_blank: skip when blank;
- if: run only when a predicate is true;
- unless: skip when a predicate is true;
- on: run in named contexts;
- except_on: exclude named contexts.

Rails supports symbol/proc/array-style conditional guards and validation contexts.

Prefer named predicate methods for non-trivial conditions so the rule is inspectable and testable. Keep inline procs for genuinely local predicates.

Avoid a large web of interacting conditions. If the validation matrix becomes workflow orchestration, move that workflow to a higher-level boundary.
