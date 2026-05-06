require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)

    post session_url, params: {
      email_address: @user.email_address,
      password: "password"
    }

    @feature = Feature.find_or_create_by!(name: "パソコン")

    @inquiry = Inquiry.create!(
      title: "テスト問い合わせ",
      body: "問い合わせ内容です",
      response_content: "対応内容です",
      status: :unhandled,
      priority: :medium,
      due_date: Date.current,
      assignee: @user,
      features: [ @feature ],
      customer_name: "テスト顧客",
      phone_number: "090-0000-0000"
    )
  end

  test "should get index" do
    get inquiries_url
    assert_response :success
  end

  test "should get show" do
    get inquiry_url(@inquiry)
    assert_response :success
  end

  test "should get new" do
    get new_inquiry_url
    assert_response :success
  end

  test "should get edit" do
    get edit_inquiry_url(@inquiry)
    assert_response :success
  end

  test "should create inquiry" do
    assert_difference("Inquiry.count", 1) do
      post inquiries_url, params: {
        inquiry: {
          title: "新規問い合わせ",
          body: "新規問い合わせ内容です",
          response_content: "新規対応内容です",
          status: "unhandled",
          priority: "medium",
          due_date: Date.current,
          customer_name: "新規顧客",
          phone_number: "090-1111-2222",
          feature_ids: [ @feature.id ]
        }
      }
    end

    assert_redirected_to inquiries_url
  end

  test "should update inquiry" do
    patch inquiry_url(@inquiry), params: {
      inquiry: {
        title: "更新後タイトル",
        body: "更新後問い合わせ内容です",
        response_content: "更新後対応内容です",
        status: "in_progress",
        priority: "high",
        due_date: Date.current,
        customer_name: "更新後顧客",
        phone_number: "090-3333-4444",
        feature_ids: [ @feature.id ]
      },
      status_change_reason: "対応を開始したため"
    }

    assert_redirected_to inquiries_url
  end
end
