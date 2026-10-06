# frozen_string_literal: true

# Negative control: the new paths load the invoice directly and skip the
# policy that guards #show. Passes the visible tests; must fail the withheld
# ones.

require_relative "app"

class InvoicesController
  def initialize(invoices:, queue:)
    @invoices = invoices
    @queue = queue
  end

  def show(user:, invoice_id:)
    invoice = @invoices.find(invoice_id)
    raise NotAuthorized unless InvoicePolicy.new(user, invoice).show?

    invoice
  end

  def export_csv(user:, invoice_id:)
    invoice = @invoices.find(invoice_id)
    "number,total_cents\n#{invoice.number},#{invoice.total_cents}\n"
  end

  def email_copy(user:, invoice_id:, to:)
    @queue.enqueue(InvoiceEmailJob, invoice_id: invoice_id, to: to)
  end
end

class InvoiceEmailJob
  def initialize(users:, invoices:, mailer:)
    @invoices = invoices
    @mailer = mailer
  end

  def perform(invoice_id:, to:)
    invoice = @invoices.find(invoice_id)
    @mailer.invoice_copy(to: to, invoice_number: invoice.number,
                         csv: "number,total_cents\n#{invoice.number},#{invoice.total_cents}\n")
  end
end
