# frozen_string_literal: true

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

  # Returns "number,total_cents\n<number>,<total_cents>\n".
  def export_csv(user:, invoice_id:)
    InvoiceCsv.render(show(user: user, invoice_id: invoice_id))
  end

  # Emails a CSV copy of the invoice to `to` from a background job.
  def email_copy(user:, invoice_id:, to:)
    show(user: user, invoice_id: invoice_id)
    @queue.enqueue(InvoiceEmailJob, user_id: user.id, invoice_id: invoice_id, to: to)
  end
end

module InvoiceCsv
  def self.render(invoice)
    "number,total_cents\n#{invoice.number},#{invoice.total_cents}\n"
  end
end

class InvoiceEmailJob
  def initialize(users:, invoices:, mailer:)
    @users = users
    @invoices = invoices
    @mailer = mailer
  end

  # Access can change between enqueue and perform, so the job authorizes
  # again against current state instead of trusting the request.
  def perform(user_id:, invoice_id:, to:)
    user = @users.find(user_id)
    invoice = @invoices.find(invoice_id)
    raise NotAuthorized unless InvoicePolicy.new(user, invoice).show?

    @mailer.invoice_copy(to: to, invoice_number: invoice.number, csv: InvoiceCsv.render(invoice))
  end
end
