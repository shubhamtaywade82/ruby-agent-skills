class DashboardController < ApplicationController
  # Private endpoint: the existing authentication mechanism runs before the action.
  before_action :authenticate_user!

  def show
  end
end
