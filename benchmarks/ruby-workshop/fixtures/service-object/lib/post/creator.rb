require_relative "../application_service"
require_relative "../post"
require_relative "../status"

class Post
  class Creator < ApplicationService
    def initialize(user, status_text:)
      @user = user
      @status_text = status_text
    end

    def call
      raise NotImplementedError
    end
  end
end
