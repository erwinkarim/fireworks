class CreateMachineFeatureData < ActiveRecord::Migration
  def change
    create_table :machine_feature_data do |t|
      t.references :machine
      t.references :feature

      t.timestamps
    end
    add_index :machine_feature_data, :machine_id
    add_index :machine_feature_data, :feature_id
  end
end
