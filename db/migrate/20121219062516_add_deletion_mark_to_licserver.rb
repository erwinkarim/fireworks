class AddDeletionMarkToLicserver < ActiveRecord::Migration
  def change
    add_column :licservers, :to_delete, :boolean
  end
end
