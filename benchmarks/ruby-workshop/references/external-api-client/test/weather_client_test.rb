require "json"
require "minitest/autorun"
require_relative "../lib/weather_client"

class WeatherClientTest < Minitest::Test
  Response = Struct.new(:status, :body)

  class FakeTransport
    def initialize(response)
      @response = response
    end

    def get(_city)
      @response
    end
  end

  def client(status, body)
    WeatherClient.new(http: FakeTransport.new(Response.new(status, body)))
  end

  def test_normalizes_success_payload
    body = JSON.generate("city" => "Pune", "temperature" => 28, "humidity" => 70)
    assert_equal({ "city" => "Pune", "temperature" => 28 }, client(200, body).fetch("Pune"))
  end

  def test_non_success_status_raises
    assert_raises(WeatherClient::Error) { client(503, "{}").fetch("Pune") }
  end

  def test_malformed_json_raises
    assert_raises(WeatherClient::Error) { client(200, "not json").fetch("Pune") }
  end

  def test_missing_fields_raise
    assert_raises(WeatherClient::Error) { client(200, JSON.generate("city" => "Pune")).fetch("Pune") }
  end
end
