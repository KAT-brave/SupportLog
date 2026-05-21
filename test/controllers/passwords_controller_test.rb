require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @user = users(:one)
  end

  test "new" do
    get new_password_url

    assert_response :success
    assert_match "パスワード", response.body
  end

  test "create shows pseudo mail preview for an existing user" do
    assert_no_enqueued_emails do
      post passwords_url, params: { email_address: @user.email_address }
    end

    assert_redirected_to new_session_url

    follow_redirect!

    assert_response :success
    assert_match "パスワード再設定用の案内を表示しました。", response.body
    assert_match "疑似メール内容", response.body
    assert_match "パスワード再設定画面を開く", response.body
  end

  test "create for an unknown user redirects but shows no pseudo mail preview" do
    assert_no_enqueued_emails do
      post passwords_url, params: { email_address: "unknown@example.com" }
    end

    assert_redirected_to new_session_url

    follow_redirect!

    assert_response :success
    assert_match "パスワード再設定用の案内を表示しました。", response.body
    assert_no_match "疑似メール内容", response.body
    assert_no_match "パスワード再設定画面を開く", response.body
  end

  test "edit with invalid password reset token" do
    get edit_password_url("invalid-token")

    assert_redirected_to new_password_url

    follow_redirect!

    assert_response :success
    assert_match "パスワード再設定リンクが無効、または有効期限が切れています。", response.body
  end

  test "edit" do
    get edit_password_url(@user.password_reset_token)

    assert_response :success
    assert_match "新しいパスワードを設定", response.body
  end

  test "update" do
    assert_changes -> { @user.reload.password_digest } do
      patch password_url(@user.password_reset_token),
            params: {
              password: "NewPassword123!",
              password_confirmation: "NewPassword123!"
            }

      assert_redirected_to new_session_url
    end

    follow_redirect!

    assert_response :success
    assert_match "パスワードを再設定しました。新しいパスワードでログインしてください。", response.body
  end

  test "update with non matching passwords" do
    token = @user.password_reset_token

    assert_no_changes -> { @user.reload.password_digest } do
      patch password_url(token),
            params: {
              password: "NewPassword123!",
              password_confirmation: "DifferentPassword123!"
            }

      assert_response :unprocessable_entity
    end

    assert_match "新しいパスワードを設定", response.body
    assert_match "一致", response.body
  end
end
