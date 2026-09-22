# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/solution"

class ReportsControllerTest < Minitest::Test
  def setup
    @reports = {
      1 => { user_id: 7, name: "Revenue", version: 2, rows: [["date", "amount"], ["2026-01-01", "10"]] }
    }
    @controller = ReportsController.new(reports: @reports)
  end

  def test_json_and_html_have_explicit_response_contract
    json = @controller.index(params: { report: { id: 1, ignored: "attack" } }, current_user: 7, format: :json)
    html = @controller.index(params: { report: { id: 1 } }, current_user: 7, format: :html)

    assert_equal 200, json[:status]
    assert_equal "application/json", json[:content_type]
    assert_equal "text/html", html[:content_type]
    refute json[:body].is_a?(Hash) && json[:body].key?(:ignored)
  end

  def test_invalid_nested_input_and_unsupported_format_are_deterministic
    invalid = @controller.index(params: { report: {} }, current_user: 7, format: :json)
    unsupported = @controller.index(params: { report: { id: 1 } }, current_user: 7, format: :xml)

    assert_equal 400, invalid[:status]
    assert_equal 406, unsupported[:status]
  end

  def test_unauthorized_resource_is_rejected
    assert_equal 403, @controller.index(params: { id: 1 }, current_user: 99, format: :json)[:status]
  end

  def test_conditional_request_can_return_not_modified
    first = @controller.index(params: { id: 1 }, current_user: 7, format: :json)
    response = @controller.index(
      params: { id: 1 },
      current_user: 7,
      format: :json,
      if_none_match: first[:etag]
    )

    assert_equal 304, response[:status]
  end

  def test_download_is_explicit_and_bounded
    response = @controller.download(params: { id: 1 }, current_user: 7)

    assert_equal "text/csv", response[:content_type]
    assert_instance_of Enumerator, response[:body]
    assert_equal "date,amount
", response[:body].next
  end
end
