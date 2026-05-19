# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_19_213405) do
  create_table "feature_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "feature_id", null: false
    t.integer "inquiry_id", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_id"], name: "index_feature_assignments_on_feature_id"
    t.index ["inquiry_id"], name: "index_feature_assignments_on_inquiry_id"
  end

  create_table "features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "inquiries", force: :cascade do |t|
    t.integer "assignee_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.string "customer_name"
    t.text "delete_reason"
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.date "due_date"
    t.string "inquiry_no"
    t.string "phone_number"
    t.integer "priority"
    t.text "response_content"
    t.integer "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.index ["assignee_id"], name: "index_inquiries_on_assignee_id"
    t.index ["created_by_id"], name: "index_inquiries_on_created_by_id"
    t.index ["deleted_by_id"], name: "index_inquiries_on_deleted_by_id"
    t.index ["inquiry_no"], name: "index_inquiries_on_inquiry_no", unique: true
    t.index ["updated_by_id"], name: "index_inquiries_on_updated_by_id"
  end

  create_table "inquiry_status_histories", force: :cascade do |t|
    t.integer "changed_by_id", null: false
    t.datetime "created_at", null: false
    t.integer "from_status"
    t.integer "inquiry_id", null: false
    t.text "reason"
    t.integer "to_status"
    t.datetime "updated_at", null: false
    t.index ["changed_by_id"], name: "index_inquiry_status_histories_on_changed_by_id"
    t.index ["inquiry_id"], name: "index_inquiry_status_histories_on_inquiry_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin"
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "rejected_at"
    t.text "rejection_reason"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "feature_assignments", "features"
  add_foreign_key "feature_assignments", "inquiries"
  add_foreign_key "inquiries", "users", column: "assignee_id"
  add_foreign_key "inquiries", "users", column: "created_by_id"
  add_foreign_key "inquiries", "users", column: "deleted_by_id"
  add_foreign_key "inquiries", "users", column: "updated_by_id"
  add_foreign_key "inquiry_status_histories", "inquiries"
  add_foreign_key "inquiry_status_histories", "users", column: "changed_by_id"
  add_foreign_key "sessions", "users"
end
