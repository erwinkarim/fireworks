class AddDomainToAdsUser < ActiveRecord::Migration
  def change
    add_column :ads_users, :domain, :string
  end
end
