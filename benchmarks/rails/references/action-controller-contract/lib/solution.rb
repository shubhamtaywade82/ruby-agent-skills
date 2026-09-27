# frozen_string_literal: true

class ReportsController
  CONTENT_TYPES = { json: "application/json", html: "text/html" }.freeze

  def initialize(reports:)
    @reports = reports
  end

  def index(params:, current_user:, format:, if_none_match: nil)
    return { status: 406, body: "unsupported format" } unless CONTENT_TYPES.key?(format)

    id, report = find_report(params)
    return { status: 400, body: "invalid report input" } unless report
    return forbidden unless authorize(report, current_user)

    # The validator covers every representation dimension: resource, version, format.
    tag = %("#{id}-#{report.fetch(:version)}-#{format}")
    return { status: 304, etag: tag, body: "" } if if_none_match == tag

    {
      status: 200,
      content_type: CONTENT_TYPES.fetch(format),
      etag: tag,
      body: format == :json ? { id: id, name: report.fetch(:name) } : report.fetch(:name)
    }
  end

  def download(params:, current_user:)
    _id, report = find_report(params)
    return { status: 400, body: "invalid report input" } unless report
    return forbidden unless authorize(report, current_user)

    rows = report.fetch(:rows)
    {
      status: 200,
      content_type: "text/csv",
      disposition: "attachment",
      body: Enumerator.new { |yielder| rows.each { |row| yielder << "#{row.join(",")}\n" } }
    }
  end

  private

  # Accepts only the report id, from either the nested or the flat shape.
  def find_report(params)
    scoped = params[:report].is_a?(Hash) ? params[:report] : params
    id = scoped[:id]
    report = id && @reports[id]
    report ? [id, report] : [nil, nil]
  end

  def authorize(report, current_user)
    report.fetch(:user_id) == current_user
  end

  def forbidden
    { status: 403, body: "forbidden" }
  end
end
