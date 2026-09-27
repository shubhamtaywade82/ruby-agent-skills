require_relative "../application_service"
require_relative "../post"
require_relative "../status"

class Post
  class Creator < ApplicationService
    def initialize(user, status_text:)
      @user = user
      @status_text = status_text
    end

    # Validates before building anything, so a failure never leaves a
    # partially created post on the user.
    def call
      validate!
      post = Post.new(user: @user, status: build_status)
      @user.posts << post
      post
    end

    private

    def validate!
      raise ArgumentError, "user is required" if @user.nil?
      raise ArgumentError, "status_text can't be blank" if @status_text.to_s.strip.empty?
    end

    def build_status
      Status.new(text: @status_text)
    end
  end
end
