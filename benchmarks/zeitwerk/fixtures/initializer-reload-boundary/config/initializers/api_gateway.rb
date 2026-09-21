# frozen_string_literal: true

Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.test"
end
