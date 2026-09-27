# frozen_string_literal: true
class ArticleView
  def initialize(locale_templates:) = @locale_templates=locale_templates
  def render_partial(article:,strict: true)
    raise NotImplementedError
  end
  def render_layout(body:,layout: :application) = raise(NotImplementedError)
  def localized_template(locale) = raise(NotImplementedError)
  def helper_format(article) = raise(NotImplementedError)
  def render_collection(articles:) = raise(NotImplementedError)
  private
  def escape(v) = raise(NotImplementedError)
  def sanitize(v) = raise(NotImplementedError)
end
