# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

# Withheld from the agent workspace: the invoice is reachable through every
# new path, not only #show, and access can change while a job waits.
class InvoicesControllerWithheldTest < Minitest::Test
  def setup
    @owner = User.new(id: 1, account_id: 10)
    @outsider = User.new(id: 2, account_id: 20)
    @users = Repository.new([@owner, @outsider])
    @invoices = Repository.new([Invoice.new(id: 7, account_id: 10, number: "INV-7", total_cents: 4200)])
    @mailer = Mailer.new
    @queue = JobQueue.new(users: @users, invoices: @invoices, mailer: @mailer)
    @controller = InvoicesController.new(invoices: @invoices, queue: @queue)
  end

  def perform_jobs
    @queue.perform_all
  rescue NotAuthorized
    nil # a denied job is an acceptable outcome; a delivery is not
  end

  def test_outsider_cannot_export
    assert_raises(NotAuthorized) { @controller.export_csv(user: @outsider, invoice_id: 7) }
  end

  def test_outsider_cannot_receive_a_copy
    begin
      @controller.email_copy(user: @outsider, invoice_id: 7, to: "eve@example.com")
    rescue NotAuthorized
      nil
    end
    perform_jobs

    assert_empty @mailer.deliveries
  end

  def test_access_revoked_after_enqueue_blocks_delivery
    @controller.email_copy(user: @owner, invoice_id: 7, to: "ada@example.com")
    @users.update(@owner.id, account_id: 20)
    perform_jobs

    assert_empty @mailer.deliveries
  end
end
