# frozen_string_literal: true

class Errors
  attr_reader :details

  def initialize
    @details = Hash.new { |hash, key| hash[key] = [] }
  end

  def add(attribute, type, message)
    @details[attribute] << { type: type, message: message }
  end

  def empty?
    @details.values.all?(&:empty?)
  end
end

class ReusableDomainValidator
  def initialize(&predicate)
    @predicate = predicate
  end

  def validate(value, errors:, attribute:)
    errors.add(attribute, :invalid, "is invalid") unless @predicate.call(value)
  end
end

class TenantTokenUniqueness
  def initialize(tokens = {})
    @tokens = tokens
  end

  def available?(tenant_id:, token:, except_id: nil)
    @tokens.none? { |id, row| row[:tenant_id] == tenant_id && row[:token] == token && id != except_id }
  end
end

class Project
  attr_reader :errors

  def initialize(name:, tenant_id:, published: false, description: nil, domain_rule: nil)
    @name = name
    @tenant_id = tenant_id
    @published = published
    @description = description
    @domain_rule = domain_rule
    @errors = Errors.new
  end

  def valid?(context: nil)
    @errors = Errors.new
    @errors.add(:name, :blank, "can't be blank") if @name.to_s.empty?
    if context == :publish && @description.to_s.empty?
      @errors.add(:description, :blank, "must be present to publish")
    end
    @domain_rule&.validate(@name, errors: @errors, attribute: :name)
    @errors.empty?
  end
end

class Invitation
  attr_reader :errors

  def initialize(delivery: :email, address: nil)
    @delivery = delivery
    @address = address
    @errors = Errors.new
  end

  def valid?
    @errors = Errors.new
    if @delivery == :email && @address.to_s.empty?
      @errors.add(:address, :blank, "required for email delivery")
    end
    @errors.empty?
  end
end
