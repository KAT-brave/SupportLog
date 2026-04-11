class CreateInquiryStatusHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiry_status_histories do |t|
      t.references :inquiry, null: false, foreign_key: true
      t.integer :from_status
      t.integer :to_status
      t.text :reason
      t.references :changed_by, null: false, foreign_key: true

      t.timestamps
    end
  end
end
