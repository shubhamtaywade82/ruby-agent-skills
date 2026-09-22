class WeatherClient
  def initialize(http:)
    @http = http
  end

  def fetch(city)
    raise NotImplementedError
  end
end
