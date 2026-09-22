# frozen_string_literal: true
class ArticleView
  def initialize(locale_templates:) = @locale_templates=locale_templates
  def render_partial(article:,strict: true)
    raise ArgumentError,"article required" if strict && !article
    "<article><h1>#{escape(article.fetch(:title))}</h1><p>#{sanitize(article.fetch(:summary))}</p></article>"
  end
  def render_layout(body:,layout: :application) = layout==:application ? "<main>#{body}</main>" : "<section>#{body}</section>"
  def localized_template(locale) = @locale_templates.fetch(locale){@locale_templates.fetch(:default)}
  def helper_format(article) = article.fetch(:title).strip
  def render_collection(articles:) = articles.map{|article|render_partial(article:article)}
  private
  def escape(v) = v.gsub("&","&amp;").gsub("<","&lt;").gsub(">","&gt;")
  def sanitize(v) = escape(v).gsub(/&lt;br&gt;/,"<br>")
end
