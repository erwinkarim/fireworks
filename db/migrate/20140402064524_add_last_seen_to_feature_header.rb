class AddLastSeenToFeatureHeader < ActiveRecord::Migration
  def change
    add_column :feature_headers, :last_seen, :datetime
  end
end
