demo_admin_password = ENV.fetch("DEMO_ADMIN_PASSWORD", "DemoPass123!")

admin = User.find_or_initialize_by(email_address: "demo-admin@example.com")

admin.assign_attributes(
  name: "評価用管理者",
  password: demo_admin_password,
  password_confirmation: demo_admin_password,
  admin: true,
  approved_at: Time.current,
  rejected_at: nil,
  rejection_reason: nil,
  deleted_at: nil
)

admin.save!

Feature.find_or_create_by!(name: "パソコン")
Feature.find_or_create_by!(name: "タブレット")

puts "評価用管理者アカウントを作成しました"
puts "email: demo-admin@example.com"
