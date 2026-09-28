# Code-smell baseline for the Standards axis

Reference for the `change-review` skill. Load it on demand when running the Standards axis on a diff that contains Ruby or Rails code. The review procedure and invariants stay in the skill's `SKILL.md`.

## How to apply the baseline

The baseline applies even when the repository documents no standards. Two rules bind it:

- **The repository overrides.** A documented standard, a skill change contract, or an established repository convention always wins. When one of them endorses a shape the baseline would flag, drop the smell.
- **Always a judgement call.** Report each smell as "possible <smell>", quote the hunk, and say why it applies here. Skip anything a configured tool (RuboCop, a type checker, CI) already enforces.

Match smells against the diff, not against untouched code.

## Smells

Each entry: what it looks like in Ruby or Rails, then the usual fix.

- **Mysterious name**: a method, variable, or class whose name hides what it does or holds (`process`, `data`, `handle_it`, `Manager`). → Rename; if no honest name comes, the design is unclear.
- **Duplicated code**: the same logic shape in several hunks or files of the change, such as two controllers building the same query or two jobs formatting the same payload. → Extract the shared shape to its natural owner (a model method, a scope, a PORO) and call it from both.
- **Feature envy**: a method that reads mostly another object's attributes, such as a service computing a value from six `invoice.*` calls. → Move the method onto the object whose data it uses.
- **Data clumps**: the same few values travel together through arguments and hashes (`street, city, postcode`). → Give them a value object and pass that.
- **Primitive obsession**: a string, integer, or hash standing in for a domain concept (money as a float, status as a bare string compared in many places). → A small value type, an enum, or a domain object.
- **Repeated conditionals on type**: the same `case`/`when` or `if` cascade on a type or status recurs across the change. → Polymorphism, or one lookup table both sites share.
- **Shotgun surgery**: one logical change forces edits scattered across many files in the diff. → Gather what changes together into one module.
- **Divergent change**: one file is edited for several unrelated reasons in the same change, such as a model gaining formatting, HTTP calls, and scheduling. → Split so each module changes for one reason.
- **Speculative generality**: configuration, hooks, strategies, or parameters added for needs the spec does not have. → Delete and inline until a real need appears; cross-check with `stack-minimality-review`.
- **Message chains**: long navigation the caller should not depend on, such as `order.customer.account.billing_address.country`. → Hide the walk behind one method on the first object, or use `delegate` when the repository does.
- **Middle man**: a class or module that mostly forwards to one collaborator. → Remove it and call the real target; apply the deletion test from `ruby-api-design`.
- **Refused bequest**: a subclass or includer that overrides or ignores most of what it inherits, including an `ApplicationRecord` subclass that disables most callbacks or validations of a shared concern. → Replace inheritance or the mixin with composition.

## More smells

- **Redundant context argument**: a method takes an argument the receiving object already exposes through its own state or association (`order.refund(order.customer)` when `order` already has `customer`). → Read it from `self` instead of the caller's hand.
- **Control flow via exit**: `exit`, `abort`, or a `return`/`break` buried inside a loop or block used to short-circuit normal processing, rather than a value the caller can act on. → Return a domain result, or use an Enumerable method that already short-circuits (`find`, `all?`, `any?`).
- **Validation glued to parsing**: one method both gathers/parses input and validates it, so a caller cannot re-validate already-parsed input or reuse the parser alone. → Split fetching/parsing from the validation step.
- **Concern without a bounded responsibility**: an `included do ... end` module mixed in for two or more unrelated reasons. → Split into one concern per responsibility, or inline it when only one includer exists.

## Heuristics with no fixed threshold

Argument count, method length, and line length are real signals but have no single correct number that holds across repositories. Treat the repository's own linter/formatter configuration as authoritative for the number, per the boundary table above (RuboCop findings belong to `rubocop`); never invent a hard finding from an argument count or line count the repository's own tooling does not enforce.

## Rails-specific checks that are standards, not smells

These come from skill change contracts, so a breach is a hard finding when the owning skill is in scope:

- bulk writes (`update_all`, `delete_all`, `insert_all`) that skip callbacks, validations, or audit without saying so (`rails-active-record`);
- side effects in `after_save` that depend on the transaction committing (`rails-active-record`);
- `permit!` or unfiltered parameters at the controller boundary (`rails-action-controller`);
- authorization inferred from authentication, a found record, or a session value (`rails-authorization`);
- jobs that retry deterministic failures or rescue `StandardError` into silent success (`rails-active-job`).
