# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class ArticleContentTest < Minitest::Test
  def setup; @content=ArticleContent.new(article:{id:1,content:""},authorized_attachment_ids:[9]); end
  def test_malicious_markup_is_sanitized
    @content.update(raw_html:'<p>x</p><script>x</script><a href="javascript:bad">x</a>')
    refute_includes @content.render,"<script>"; refute_includes @content.render,"javascript:"
  end
  def test_attachment_authorization_is_separate
    assert @content.authorize_attachable(9); refute @content.authorize_attachable(10)
  end
  def test_api_representation_is_stable
    assert_equal 1,@content.api_representation[:id]; refute @content.api_representation.key?(:internal_storage_id)
  end
end
