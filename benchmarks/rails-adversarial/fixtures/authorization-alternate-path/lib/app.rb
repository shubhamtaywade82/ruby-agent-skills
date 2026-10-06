# frozen_string_literal: true

# Existing application code and in-memory stand-ins for the database, job
# backend, and mailer. Do not change this file.

require "json"

User = Struct.new(:id, :account_id, keyword_init: true)
Invoice = Struct.new(:id, :account_id, :number, :total_cents, keyword_init: true)

class NotAuthorized < StandardError; end

class Repository
  def initialize(records)
    @records = records.to_h { |record| [record.id, record.dup] }
  end

  def find(id)
    @records.fetch(id).dup
  end

  def update(id, **attributes)
    record = @records.fetch(id)
    attributes.each { |key, value| record[key] = value }
    record.dup
  end
end

class InvoicePolicy
  def initialize(user, invoice)
    @user = user
    @invoice = invoice
  end

  def show?
    @user.account_id == @invoice.account_id
  end
end

class Mailer
  attr_reader :deliveries

  def initialize
    @deliveries = []
  end

  def invoice_copy(to:, invoice_number:, csv:)
    @deliveries << { to: to, invoice_number: invoice_number, csv: csv }
  end
end

# Jobs run later, in another process: arguments are serialized and each job
# is built from the context (users:, invoices:, mailer:) at perform time.
class JobQueue
  def initialize(**context)
    @context = context
    @jobs = []
  end

  def enqueue(job_class, **arguments)
    unless JSON.parse(JSON.generate(arguments), symbolize_names: true) == arguments
      raise ArgumentError, "job arguments must be JSON-serializable"
    end

    @jobs << [job_class, arguments]
  end

  def perform_all
    until @jobs.empty?
      job_class, arguments = @jobs.shift
      job_class.new(**@context).perform(**arguments)
    end
  end
end
