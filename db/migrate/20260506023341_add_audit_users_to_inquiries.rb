class AddAuditUsersToInquiries < ActiveRecord::Migration[8.1]
  def change
    add_reference :inquiries, :updated_by, foreign_key: { to_table: :users }
    add_reference :inquiries, :deleted_by, foreign_key: { to_table: :users }
  end
end
