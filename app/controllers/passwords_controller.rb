class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_password_path, alert: "しばらく時間をおいてから再度お試しください。" }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      reset_path = edit_password_path(user.password_reset_token)

      flash[:mail_preview] = <<~TEXT
        【疑似メール】パスワード再設定のご案内

        パスワード再設定の申請を受け付けました。
        以下のリンクから新しいパスワードを設定してください。

        #{reset_path}

        ※評価環境では実メール送信の代わりに、この画面上に疑似メール内容を表示しています。
      TEXT

      flash[:password_reset_path] = reset_path
    end

    redirect_to new_session_path,
                notice: "パスワード再設定用の案内を表示しました。"
  end

  def edit
  end

  def update
    if @user.update(password_params)
      @user.sessions.destroy_all
      redirect_to new_session_path,
                  notice: "パスワードを再設定しました。新しいパスワードでログインしてください。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path,
                alert: "パスワード再設定リンクが無効、または有効期限が切れています。"
  end
end
