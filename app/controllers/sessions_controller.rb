class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])

    if user&.authenticate(params[:password])
      if user.rejected?
        redirect_to new_session_path, alert: "お申し込みは却下されています。詳細は通知メールをご確認ください。"
        return
      end

      unless user.approved?
        redirect_to new_session_path, alert: "現在、管理者承認待ちです。"
        return
      end

      start_new_session_for user
      redirect_to root_path, notice: "ログインしました"
    else
      redirect_to new_session_path, alert: "メールアドレスまたはパスワードが正しくありません"
    end
  end
end
