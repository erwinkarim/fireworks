class CreateMachineFeatures < ActiveRecord::Migration
  def change
    create_table :machine_features do |t|
      t.references :machine
      t.references :feature

      t.timestamps
    end
    add_index :machine_features, :machine_id
    add_index :machine_features, :feature_id
  end
end
