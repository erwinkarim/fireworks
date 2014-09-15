class AddEmailToAdsUser < ActiveRecord::Migration
  def change
    add_column :ads_users, :email, :string
  end
end
