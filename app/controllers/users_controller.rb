class UsersController < ApplicationController
  before_action :set_user, only: [:info]
  layout "main_layout"

  def info
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :password)
    end
end

