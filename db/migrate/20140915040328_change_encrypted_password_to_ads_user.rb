class ChangeEncryptedPasswordToAdsUser < ActiveRecord::Migration
  def up
		change_column(:ads_users, :encrypted_password, :string,{ :null => true, :default => ""})
  end

  def down
  end
end
