require "json"

class WeatherClient
  class Error < StandardError; end

  def initialize(http:)
    @http = http
  end

  # Normalizes the provider payload to { "city", "temperature" }; any
  # non-success status or malformed body raises WeatherClient::Error.
  def fetch(city)
    response = @http.get(city)
    raise Error, "weather request failed with status #{response.status}" unless (200..299).cover?(response.status)

    payload = JSON.parse(response.body)
    raise Error, "malformed weather payload" unless payload.is_a?(Hash) && payload.key?("city") && payload.key?("temperature")

    { "city" => payload.fetch("city"), "temperature" => payload.fetch("temperature") }
  rescue JSON::ParserError => e
    raise Error, "malformed weather payload: #{e.message}"
  end
end
