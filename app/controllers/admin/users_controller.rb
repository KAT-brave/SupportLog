module Admin
  class UsersController < ApplicationController
    before_action :require_admin

    def index
      @users = User.order(created_at: :desc)
    end

    def approve
      user = User.find(params[:id])
      user.update!(
        approved_at: Time.current,
        rejected_at: nil,
        rejection_reason: nil
      )

      UserMailer.with(user: user).approval_notification.deliver_now

      redirect_to admin_users_path, notice: "ユーザーを承認しました。"
    end

    def reject
      user = User.find(params[:id])

      if user.approved?
        redirect_to admin_users_path, alert: "承認済みユーザーは却下できません。"
        return
      end

      reason = params[:rejection_reason]

      user.update!(
        rejected_at: Time.current,
        rejection_reason: reason,
        approved_at: nil
      )

      UserMailer.with(user: user, reason: reason).rejection_notification.deliver_now

      redirect_to admin_users_path, notice: "ユーザーを却下しました。"
    end

    def destroy
      @user = User.find(params[:id])

      if @user.demo_admin_account?
        redirect_to admin_users_path,
                    alert: "評価用管理者アカウントは削除できません。"
        return
      end

      unless @user.deletable_by_admin?
        redirect_to admin_users_path,
                    alert: "このユーザーは未対応または対応中の問い合わせを担当しているため削除できません。すべて完了にしてから削除してください。"
        return
      end

      @user.soft_delete!

      redirect_to admin_users_path, notice: "ユーザーを削除しました。"
    end

    private

    def require_admin
      redirect_to root_path, alert: "権限がありません" unless Current.user&.admin?
    end
  end
end
