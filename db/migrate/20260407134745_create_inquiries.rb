class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.string :inquiry_no
      t.string :title
      t.text :body
      t.string :customer_name
      t.string :phone_number
      t.integer :status
      t.integer :priority
      t.date :due_date
      t.references :assignee, null: false, foreign_key: true
      t.text :delete_reason
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
