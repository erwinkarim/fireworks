class AddUniqExemptToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uniq_exempt, :boolean
  end
end
