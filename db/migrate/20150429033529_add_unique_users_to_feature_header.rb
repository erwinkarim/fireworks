class AddUniqueUsersToFeatureHeader < ActiveRecord::Migration
  def change
    add_column :feature_headers, :uniq_users, :boolean
  end
end
