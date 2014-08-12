class AddLoginToAdsUser < ActiveRecord::Migration
  def change
    add_column :ads_users, :login, :string, :null => false, :default => "", :unique => true
		remove_column :ads_users, :email
  end
end
