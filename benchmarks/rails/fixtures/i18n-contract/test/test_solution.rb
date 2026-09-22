# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class I18nContractTest < Minitest::Test
  def setup; @resolver=LocaleResolver.new; @translator=NotificationTranslator.new; end
  def test_supported_and_unsupported_locales
    assert_equal :fr,@resolver.resolve(:fr); assert_equal :en,@resolver.resolve(:xx)
  end
  def test_locale_is_scoped
    value=@resolver.with_locale(:fr){@resolver.resolve(:fr)}; assert_equal :fr,value
  end
  def test_pluralization_and_cache_identity
    assert_equal "2 notifications",@translator.pluralize(2,locale: :en)
    refute_equal @translator.cache_key(1,locale: :en),@translator.cache_key(1,locale: :fr)
  end
  def test_job_locale_is_explicit
    assert_equal({locale: :fr},@translator.propagate_to_job(locale: :fr))
  end
end
