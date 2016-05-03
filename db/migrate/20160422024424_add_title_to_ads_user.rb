class AddTitleToAdsUser < ActiveRecord::Migration
  def change
    add_column :ads_users, :title, :string
  end
end
