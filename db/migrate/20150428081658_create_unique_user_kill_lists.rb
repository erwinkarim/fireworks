class CreateUniqueUserKillLists < ActiveRecord::Migration
  def change
    create_table :unique_user_kill_lists do |t|
      t.references :licserver, index: true
      t.string :feature_name

      t.timestamps
    end
  end
end
