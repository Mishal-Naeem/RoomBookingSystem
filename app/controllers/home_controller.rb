class HomeController < ApplicationController
  def index
  end

  def sign_out_user
    sign_out(current_user)
    redirect_to root_path, notice: "You have been signed out successfully."
  end
end
