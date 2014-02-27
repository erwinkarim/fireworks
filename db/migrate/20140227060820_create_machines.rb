class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :name
      t.references :user

      t.timestamps
    end
    add_index :machines, :user_id
  end
end
