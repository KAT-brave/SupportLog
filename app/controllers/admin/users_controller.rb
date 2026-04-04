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

      redirect_to admin_users_path, notice: "ユーザーを承認し、通知メールを送信しました。"
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

      redirect_to admin_users_path, notice: "ユーザーを却下し、通知メールを送信しました。"
    end

    def destroy
      user = User.find(params[:id])

      unless user.approved?
        redirect_to admin_users_path, alert: "承認済みユーザーのみ削除できます。"
        return
      end

      email_address = user.email_address
      user.destroy!

      UserMailer.with(email_address: email_address).account_deleted_notification.deliver_now

      redirect_to admin_users_path, notice: "ユーザーを削除し、通知メールを送信しました。"
    end

    private

    def require_admin
      redirect_to root_path, alert: "権限がありません" unless Current.user&.admin?
    end
  end
end
