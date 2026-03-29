class UserMailer < ApplicationMailer
  def approval_notification
    @user = params[:user]

    mail to: @user.email_address, subject: "【SupportLog】申込承認のお知らせ"
  end
end