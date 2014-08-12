class CreateAdsUsers < ActiveRecord::Migration
  def change
    create_table :ads_users do |t|
      t.string :name

      t.timestamps
    end
  end
end
