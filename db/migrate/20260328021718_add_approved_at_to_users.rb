class AddApprovedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :approved_at, :datetime
    add_column :users, :admin, :boolean
  end
end
