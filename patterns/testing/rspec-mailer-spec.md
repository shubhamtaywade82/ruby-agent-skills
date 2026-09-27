---
name: rspec-mailer-spec
description: "Test a mailer's recipients, headers, and rendered content with an RSpec mailer spec."
family: testing
---

# RSpec Mailer Spec

## Problem
Mailer regressions (wrong recipient, missing subject interpolation, broken template) pass request specs that only assert enqueueing.

## Use when
The repository uses RSpec and a change touches a mailer method, its template, or its recipient rules.

## Do not use when
Only the enqueue matters for the change and the mailer is covered elsewhere.

## Repository inspection
Inspect `ApplicationMailer` defaults, layouts, template formats (text/html), recipient rules, and i18n of subjects.

## Implementation procedure
1. Build the mail with `described_class.method(args)`; do not deliver it.
2. Assert `to`, `from`, and `subject` exactly.
3. Assert on `mail.body.encoded` (or each part) for the content the user relies on.
4. Keep enqueue assertions in the request or job spec.

## Example

Runs green with rspec-rails 8.0 on Rails 8.0.

```ruby
require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe "#confirmation" do
    let(:order) { create(:order, sku: "BOOK-1", quantity: 2, email: "buyer@example.com") }
    let(:mail) { described_class.confirmation(order) }

    it "addresses the order's customer" do
      expect(mail.to).to eq(["buyer@example.com"])
      expect(mail.from).to eq(["orders@example.com"])
      expect(mail.subject).to eq("Order ##{order.id} confirmed")
    end

    it "renders the order details" do
      expect(mail.body.encoded).to include("2 x BOOK-1 is confirmed")
    end
  end
end
```

## Failure modes
Delivering real email in tests, asserting only that a mail object exists, and testing recipients through the database instead of the mail headers.

## Testing
Change the subject, recipient, or template text and confirm the spec fails.

## Review checklist
Are recipients, subject, and the essential body content asserted?

## Related skills
rails-test-engineering,rails-action-mailer
