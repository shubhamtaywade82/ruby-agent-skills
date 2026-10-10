# frozen_string_literal: true

# In-memory stand-ins for the ORM and the transactional-email provider.
# Treat them as the framework: do not change this file.
#
# Member.save writes the row and then runs the hooks registered on the
# class: after_save on every save, after_create only when the save inserted
# a new row. Member.import bulk-inserts the way insert_all does: one
# transaction, no hooks, no instances. Mailer.deliver_welcome is immediate
# and sits outside the store's transactions, the way an SMTP call would.

require_relative "store"

class Mailer
  @deliveries = []

  class << self
    attr_reader :deliveries

    def deliver_welcome(member_id)
      deliveries << { member_id: member_id, template: "welcome" }
    end

    def reset
      @deliveries = []
    end
  end
end

class Member
  @save_hooks = []
  @create_hooks = []
  @store = nil

  class << self
    attr_reader :save_hooks, :create_hooks, :store

    def connect(store)
      @store = store
    end

    # Registers a lifecycle hook. save runs these methods, in registration
    # order, after the row is written.
    def after_save(method_name)
      save_hooks << method_name
    end

    def after_create(method_name)
      create_hooks << method_name
    end

    def find(id)
      row = store.find_by(:members, id: id)
      raise KeyError, "no member #{id}" unless row

      new(row)
    end

    # Bulk insert: one transaction, no hooks, no instances — the way
    # insert_all skips callbacks and dirty tracking.
    def import(rows)
      store.transaction do
        rows.map { |attributes| store.insert(:members, attributes) }
      end
    end
  end

  attr_reader :id

  def initialize(attributes = {})
    @attributes = attributes
    @id = attributes[:id]
  end

  def email
    @attributes.fetch(:email)
  end

  def name
    @attributes.fetch(:name)
  end

  def status
    @attributes.fetch(:status)
  end

  # Writes the row, then runs the registered hooks: after_save on every
  # save, after_create only when this save inserted the row.
  def save
    inserted = persist
    self.class.save_hooks.each { |hook| send(hook) }
    self.class.create_hooks.each { |hook| send(hook) } if inserted
    self
  end

  def update(attributes)
    @attributes = @attributes.merge(attributes)
    save
  end

  private

  def persist
    if @id
      self.class.store.update(:members, @id, @attributes)
      false
    else
      row = self.class.store.insert(:members, @attributes)
      @id = row.fetch(:id)
      true
    end
  end
end
