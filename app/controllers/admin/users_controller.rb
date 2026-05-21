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

      mail = UserMailer.with(user: user).approval_notification
      flash[:mail_preview] = notification_preview_text(mail)

      redirect_to admin_users_path, notice: "ユーザーを承認しました。疑似メール内容を画面に表示しています。"
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

      mail = UserMailer.with(user: user, reason: reason).rejection_notification
      flash[:mail_preview] = notification_preview_text(mail)

      redirect_to admin_users_path, notice: "ユーザーを却下しました。疑似メール内容を画面に表示しています。"
    end

    def update_role
      user = User.find(params[:id])

      if user.demo_admin_account?
        redirect_to admin_users_path,
                    alert: "評価用管理者アカウントの権限は変更できません。"
        return
      end

      if user == Current.user
        redirect_to admin_users_path,
                    alert: "現在ログイン中の自分自身の権限は変更できません。"
        return
      end

      unless user.approved?
        redirect_to admin_users_path,
                    alert: "未承認ユーザーの権限は変更できません。先に承認してください。"
        return
      end

      user.update!(admin: params[:admin] == "true")

      redirect_to admin_users_path, notice: "ユーザー権限を更新しました。"
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

      mail = UserMailer.with(user: @user).account_deleted_notification
      flash[:mail_preview] = notification_preview_text(mail)

      @user.soft_delete!

      redirect_to admin_users_path, notice: "ユーザーを削除しました。疑似メール内容を画面に表示しています。"
    end

    private

    def require_admin
      redirect_to root_path, alert: "権限がありません" unless Current.user&.admin?
    end

    def notification_preview_text(mail)
      <<~TEXT
        【疑似メール】
        ※ ポートフォリオ用途のため、実際のメール送信は行っていません。

        宛先: #{Array(mail.to).join(", ")}
        件名: #{mail.subject}

        #{mail_body(mail)}
      TEXT
    end

    def mail_body(mail)
      if mail.text_part
        mail.text_part.body.decoded
      else
        mail.body.decoded
      end
    end
  end
end
