class AddRejectionFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :rejected_at, :datetime
    add_column :users, :rejection_reason, :text
  end
end
