# Signs in any user by email without a password. Added for browser tests.
class TestSessionsController < ApplicationController
  skip_forgery_protection

  def create
    user = User.find_or_create_by!(email: params.require(:email)) do |new_user|
      new_user.password = SecureRandom.hex(16)
    end
    reset_session
    session[:user_id] = user.id
    head :no_content
  end
end
