class UserMailer < ApplicationMailer
  def approval_notification
    @user = params[:user]
    mail to: @user.email_address, subject: "【サポートログ】申込承認のお知らせ"
  end

  def rejection_notification
    @user = params[:user]
    @reason = params[:reason]
    mail to: @user.email_address, subject: "【サポートログ】申込結果のお知らせ"
  end

  def account_deleted_notification
    @email_address = params[:email_address]
    mail to: @email_address, subject: "【サポートログ】アカウント削除のお知らせ"
  end
end