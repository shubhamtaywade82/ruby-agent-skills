# frozen_string_literal: true
class LocaleResolver
  def initialize(default: :en) = @default=default
  def resolve(value) = raise(NotImplementedError)
  def with_locale(value) = raise(NotImplementedError)
end
class NotificationTranslator
  def pluralize(count,locale:) = raise(NotImplementedError)
  def cache_key(resource_id,locale:) = raise(NotImplementedError)
  def propagate_to_job(locale:) = raise(NotImplementedError)
end
