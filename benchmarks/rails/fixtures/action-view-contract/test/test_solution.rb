# frozen_string_literal: true
require "minitest/autorun"
require_relative "../lib/solution"
class ArticleViewTest < Minitest::Test
  def setup; @view=ArticleView.new(locale_templates:{en:"article.en",default:"article"}); end
  def test_partial_and_output_safety
    html=@view.render_partial(article:{title:"<A>",summary:"Hello"})
    assert_includes html,"&lt;A&gt;"
  end
  def test_localized_template_falls_back
    assert_equal "article.en",@view.localized_template(:en); assert_equal "article",@view.localized_template(:de)
  end
  def test_layout_collection_and_helper
    body=@view.render_collection(articles:[{title:"One",summary:"A"}]).first
    assert_equal "One",@view.helper_format({title:"One "})
    assert_equal "<main>#{body}</main>",@view.render_layout(body:body)
  end
end
