class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user

    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.json { head :unauthorized }
    end
  end
end
