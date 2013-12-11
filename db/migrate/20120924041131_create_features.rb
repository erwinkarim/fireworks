class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :name
      t.integer :current
      t.integer :max
      t.references :licserver

      t.timestamps
    end
    add_index :features, :licserver_id
  end
end
