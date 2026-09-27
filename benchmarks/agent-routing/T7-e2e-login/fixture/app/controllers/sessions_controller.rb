class SessionsController < ApplicationController
  def new; end

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])
    if user
      reset_session
      session[:user_id] = user.id
      redirect_to notes_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path
  end
end
