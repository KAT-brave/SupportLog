class CreateFeatureAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :feature_assignments do |t|
      t.references :inquiry, null: false, foreign_key: true
      t.references :feature, null: false, foreign_key: true

      t.timestamps
    end
  end
end
