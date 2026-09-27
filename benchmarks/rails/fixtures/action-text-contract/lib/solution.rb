# frozen_string_literal: true
class ArticleContent
  def initialize(article:,authorized_attachment_ids:) = (@article,@authorized_attachment_ids=article,authorized_attachment_ids)
  def update(raw_html:) = raise(NotImplementedError)
  def render = raise(NotImplementedError)
  def api_representation = raise(NotImplementedError)
  def authorize_attachable(id) = raise(NotImplementedError)
  private
  def sanitize(html) = raise(NotImplementedError)
end
