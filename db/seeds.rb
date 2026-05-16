demo_admins = [
  {
    email_address: "demo-admin@example.com",
    name: "評価用管理者",
    password: ENV.fetch("DEMO_ADMIN_PASSWORD", "DemoPass123!")
  },
  {
    email_address: "demo-sub-admin@example.com",
    name: "予備評価用管理者",
    password: ENV.fetch("DEMO_SUB_ADMIN_PASSWORD", "DemoPass456!")
  }
]

demo_admins.each do |admin_attributes|
  admin = User.find_or_initialize_by(email_address: admin_attributes[:email_address])

  admin.assign_attributes(
    name: admin_attributes[:name],
    password: admin_attributes[:password],
    password_confirmation: admin_attributes[:password],
    admin: true,
    approved_at: Time.current,
    rejected_at: nil,
    rejection_reason: nil,
    deleted_at: nil
  )

  admin.save!
end

Feature.find_or_create_by!(name: "パソコン")
Feature.find_or_create_by!(name: "タブレット")

puts "評価用管理者アカウントを作成しました"
puts "email: demo-admin@example.com"
puts "email: demo-sub-admin@example.com"
