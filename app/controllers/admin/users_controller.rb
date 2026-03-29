module Admin
  class UsersController < ApplicationController
    before_action :require_admin

    def index
      @users = User.order(created_at: :desc)
    end

    def approve
      user = User.find(params[:id])
      user.update!(approved_at: Time.current)
      redirect_to admin_users_path, notice: "ユーザーを承認しました"
    end

    private

    def require_admin
      redirect_to root_path, alert: "権限がありません" unless Current.user&.admin?
    end
  end
end