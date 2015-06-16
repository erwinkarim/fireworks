class AddAdsUserToUser < ActiveRecord::Migration
  def change
    add_reference :users, :ads_user, index: true
  end
end
