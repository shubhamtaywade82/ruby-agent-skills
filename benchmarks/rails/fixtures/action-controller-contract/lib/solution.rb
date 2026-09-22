# frozen_string_literal: true

class ReportsController
  def initialize(reports:)
    @reports = reports
  end

  def index(params:, current_user:, format:, if_none_match: nil)
    report = @reports.fetch(params.fetch(:id))
    return forbidden unless report.fetch(:user_id) == current_user

    representation = format == :json ? { id: report.fetch(:id), name: report.fetch(:name) } : report.fetch(:name)
    tag = %("#{report.fetch(:id)}-#{report.fetch(:version)}")
    return { status: 304, body: "" } if if_none_match == tag

    {
      status: 200,
      content_type: format == :json ? "application/json" : "text/html",
      etag: tag,
      body: representation
    }
  rescue KeyError
    { status: 400, body: "invalid report input" }
  end

  def download(params:, current_user:)
    report = @reports.fetch(params.fetch(:id))
    return forbidden unless report.fetch(:user_id) == current_user

    rows = report.fetch(:rows)
    {
      status: 200,
      content_type: "text/csv",
      disposition: "attachment",
      body: Enumerator.new { |yielder| rows.each { |row| yielder << row.join(",") << "\n" } }
    }
  end

  private

  def authorize(report, current_user)
    report.fetch(:user_id) == current_user
  end

  def forbidden
    { status: 403, body: "forbidden" }
  end
end
