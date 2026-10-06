# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class InvoicesControllerTest < Minitest::Test
  def setup
    @owner = User.new(id: 1, account_id: 10)
    @users = Repository.new([@owner])
    @invoices = Repository.new([Invoice.new(id: 7, account_id: 10, number: "INV-7", total_cents: 4200)])
    @mailer = Mailer.new
    @queue = JobQueue.new(users: @users, invoices: @invoices, mailer: @mailer)
    @controller = InvoicesController.new(invoices: @invoices, queue: @queue)
  end

  def test_owner_exports_csv
    assert_equal "number,total_cents\nINV-7,4200\n", @controller.export_csv(user: @owner, invoice_id: 7)
  end

  def test_owner_receives_an_emailed_copy
    @controller.email_copy(user: @owner, invoice_id: 7, to: "ada@example.com")
    @queue.perform_all

    assert_equal [{ to: "ada@example.com", invoice_number: "INV-7", csv: "number,total_cents\nINV-7,4200\n" }],
                 @mailer.deliveries
  end
end
