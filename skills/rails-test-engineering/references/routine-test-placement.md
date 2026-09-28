# Test placement for routine changes

Reference for the `rails-test-engineering` skill. Load it on demand when deciding where a test belongs for a routine model, controller, job, or mailer change. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Test placement for routine changes

_Merged from the retired `rails-test-engineering` skill._

### Repository inspection

Resolve:

- RSpec or Minitest
- unit/model conventions
- request/controller tests
- system tests
- factories/fixtures
- test database setup
- helper/shared examples
- CI commands
- external-service stubs/fakes

Reuse the project's ecosystem.

### Test placement

Prefer the smallest useful test that proves the contract.

Examples:

- model invariant -> model test
- association behavior -> model/integration test as appropriate
- service workflow -> service/domain test
- HTTP response contract -> request test
- user interaction -> system test when the repository uses one
- cross-layer authentication -> request/integration test

A focused test and an end-to-end test may both be justified when they prove different contracts.

### Test design

Tests should explain behavior.

Prefer:

```text
setup
  -> meaningful action
  -> meaningful expectation
```

over large arrangements with opaque helpers.

Cover:

- normal cases
- edge cases
- invalid input
- authorization/authentication
- error behavior
- important side effects
- regressions

### Determinism

Avoid unnecessary:

- sleeps
- time dependence
- random data without controlled seed
- external network calls
- ordering assumptions
- shared mutable state

Use time helpers/fakes consistent with repository conventions.

### Mocking/stubbing

Mock external boundaries when appropriate, not the implementation under test.

Avoid mocking every internal method; that can make tests pass while behavior is broken.

### Regression tests

A bug fix should ideally add a test that represents the previous failure.

### Reference example

A model test for the invariant and a request test for the boundary, each failing for exactly one reason.

```ruby
class InvoiceTest < ActiveSupport::TestCase
  test "overdue scope excludes paid invoices" do
    paid = invoices(:paid)
    unpaid = invoices(:overdue)

    assert_includes Invoice.overdue, unpaid
    refute_includes Invoice.overdue, paid
  end
end

class StatementsRequestTest < ActionDispatch::IntegrationTest
  test "index redirects anonymous users to sign in" do
    get statements_path

    assert_redirected_to new_session_path
  end
end
```

### Agent review checklist

- [ ] test stack and conventions inspected
- [ ] test boundary matches behavior
- [ ] assertions describe the contract
- [ ] edge/failure cases considered
- [ ] external boundaries isolated appropriately
- [ ] tests deterministic
- [ ] no unnecessary implementation coupling

### Verification

Run focused tests first, then the affected Rails test group, then broader CI-equivalent checks where appropriate.

### Book integration: request-level testing

For HTTP behavior that crosses routing, controller, persistence, authentication, and response layers, prefer request-level tests over tests that exercise only an isolated controller implementation when the repository's test stack supports that style.

A request test should assert the observable contract: status, response body/redirect, persistence/side effects, and relevant authorization behavior.

Keep unit/service tests for local behavior and request/system tests for cross-layer contracts.
