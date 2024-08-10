class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    if @user != current_user && !current_user.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
