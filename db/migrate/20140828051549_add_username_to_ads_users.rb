class AddUsernameToAdsUsers < ActiveRecord::Migration
  def change
    add_column :ads_users, :username, :string
    add_index :ads_users, :username
  end
end
