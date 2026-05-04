class FixChangedByForeignKeyOnInquiryStatusHistories < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :inquiry_status_histories, :changed_bies
    add_foreign_key :inquiry_status_histories, :users, column: :changed_by_id
  end
end