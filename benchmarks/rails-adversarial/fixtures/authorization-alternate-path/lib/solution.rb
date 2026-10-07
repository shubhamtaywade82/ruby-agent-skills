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
    nil
  end

  # Emails a CSV copy of the invoice to `to` from a background job.
  def email_copy(user:, invoice_id:, to:)
    nil
  end
end

class InvoiceEmailJob
  def initialize(users:, invoices:, mailer:)
    @users = users
    @invoices = invoices
    @mailer = mailer
  end

  def perform(**arguments)
    nil
  end
end
