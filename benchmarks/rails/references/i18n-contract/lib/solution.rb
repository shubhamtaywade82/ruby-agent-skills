# frozen_string_literal: true
class LocaleResolver
  SUPPORTED=%i[en fr].freeze
  def initialize(default: :en) = @default=default
  def resolve(value) = SUPPORTED.include?(value.to_sym) ? value.to_sym : @default
  def with_locale(value) = yield(resolve(value))
end
class NotificationTranslator
  def pluralize(count,locale:) = locale==:fr ? (count==1 ? "1 notification" : "#{count} notifications") : (count==1 ? "1 notification" : "#{count} notifications")
  def cache_key(resource_id,locale:) = "notification:#{resource_id}:#{locale}"
  def propagate_to_job(locale:) = {locale:locale}
end
