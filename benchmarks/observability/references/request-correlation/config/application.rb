class Application
  # Reuse the framework's request id (ActionDispatch::RequestId) as the log
  # tag instead of generating a second correlation identifier.
  def self.log_tags
    [:request_id]
  end

  # Credentials in auth headers and params never reach the logs.
  def self.filter_parameters
    [:password, :token, :authorization, "HTTP_AUTHORIZATION"]
  end
end
