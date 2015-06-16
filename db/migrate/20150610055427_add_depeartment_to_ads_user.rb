class AddDepeartmentToAdsUser < ActiveRecord::Migration
  def change
    add_reference :ads_users, :ads_department, index: true
  end
end
