class CreateFeatureHeaders < ActiveRecord::Migration
  def change
    create_table :feature_headers do |t|
      t.references :licserver
      t.references :feature
      t.string :name

      t.timestamps
    end
    add_index :feature_headers, :licserver_id
    add_index :feature_headers, :feature_id
  end
end
