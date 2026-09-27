# frozen_string_literal: true

# Structured, stable error details: attribute -> [{ type:, message: }].
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

# A side-effect-free rule shared by more than one model.
class ReusableDomainValidator
  def initialize(&predicate)
    @predicate = predicate
  end

  def validate(value, errors:, attribute:)
    errors.add(attribute, :invalid, "is invalid") unless @predicate.call(value)
  end
end

# Application-level check only; the authoritative guarantee is a unique
# database index on (tenant_id, token), which bulk-import writes cannot skip.
class TenantTokenUniqueness
  def initialize(tokens = {})
    @tokens = tokens
  end

  def available?(tenant_id:, token:, except_id: nil)
    @tokens.none? { |id, row| row[:tenant_id] == tenant_id && row[:token] == token && id != except_id }
  end
end

module Validatable
  attr_reader :errors

  def valid?(context: nil)
    @errors = Errors.new
    run_validations(context)
    @errors.empty?
  end
end

class Organization
  include Validatable

  SLUG_RULE = ReusableDomainValidator.new { |value| value.to_s.match?(/\A[a-z0-9-]{3,}\z/) }

  def initialize(name:, slug:, tenant_id:)
    @name = name
    @slug = slug
    @tenant_id = tenant_id
    @errors = Errors.new
  end

  private

  def run_validations(_context)
    @errors.add(:name, :blank, "can't be blank") if @name.to_s.strip.empty?
    @errors.add(:tenant_id, :blank, "can't be blank") if @tenant_id.nil?
    SLUG_RULE.validate(@slug, errors: @errors, attribute: :slug)
  end
end

class User
  include Validatable

  def initialize(email:, organization:)
    @email = email
    @organization = organization
    @errors = Errors.new
  end

  private

  # Associated validation is bounded to the owned organization reference;
  # permission to join it is decided elsewhere.
  def run_validations(_context)
    @errors.add(:email, :blank, "can't be blank") if @email.to_s.strip.empty?
    @errors.add(:organization, :blank, "must exist") if @organization.nil?
  end
end

class Project
  include Validatable

  def initialize(name:, tenant_id:, published: false, description: nil, domain_rule: nil)
    @name = name
    @tenant_id = tenant_id
    @published = published
    @description = description
    @domain_rule = domain_rule
    @errors = Errors.new
  end

  private

  # :publish is an explicit, named context; ordinary saves do not apply it.
  def run_validations(context)
    @errors.add(:name, :blank, "can't be blank") if @name.to_s.strip.empty?
    @errors.add(:tenant_id, :blank, "can't be blank") if @tenant_id.nil?
    if context == :publish && @description.to_s.strip.empty?
      @errors.add(:description, :blank, "must be present to publish")
    end
    @domain_rule&.validate(@name, errors: @errors, attribute: :name)
  end
end

class Invitation
  include Validatable

  def initialize(delivery: :email, address: nil)
    @delivery = delivery
    @address = address
    @errors = Errors.new
  end

  private

  def run_validations(_context)
    if @delivery == :email && @address.to_s.strip.empty?
      @errors.add(:address, :blank, "required for email delivery")
    end
  end
end
