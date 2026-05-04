class UserMailer < ApplicationMailer
  def approval_notification
    @user = params[:user]
    mail to: @user.email_address, subject: "【SupportLog】申込承認のお知らせ"
  end

  def rejection_notification
    @user = params[:user]
    @reason = params[:reason]
    mail to: @user.email_address, subject: "【SupportLog】申込結果のお知らせ"
  end

  def account_deleted_notification
    @user = params[:user]
    mail(to: @user.email_address, subject: "【SupportLog】アカウント削除のお知らせ")
  end
end
