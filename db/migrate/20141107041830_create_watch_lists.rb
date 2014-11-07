class CreateWatchLists < ActiveRecord::Migration
  def change
    create_table :watch_lists do |t|
      t.references :ads_user
      t.string :model_type
      t.integer :model_id
      t.text :note

      t.timestamps
    end
    add_index :watch_lists, :ads_user_id
  end
end
