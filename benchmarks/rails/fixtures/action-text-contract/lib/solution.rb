# frozen_string_literal: true
class ArticleContent
  def initialize(article:,authorized_attachment_ids:) = (@article,@authorized_attachment_ids=article,authorized_attachment_ids)
  def update(raw_html:) = @article[:content]=sanitize(raw_html)
  def render = @article.fetch(:content)
  def api_representation = {id:@article.fetch(:id),content:render}
  def authorize_attachable(id) = @authorized_attachment_ids.include?(id)
  private
  def sanitize(html) = html.gsub(/<script.*?>.*?<\/script>/mi,"").gsub(/\son\w+="[^"]*"/i,"").gsub(%r{href="javascript:[^"]*"}i,"")
end
