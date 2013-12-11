class CreateIdleUsers < ActiveRecord::Migration
  def change
    create_table :idle_users do |t|
      t.string :user
      t.string :hostname
      t.string :idle

      t.timestamps
    end
  end
end
