class AddFhToFeature < ActiveRecord::Migration
  def change
    add_column :features, :feature_header_id, :integer
    add_index :features, :feature_header_id
  end
end
