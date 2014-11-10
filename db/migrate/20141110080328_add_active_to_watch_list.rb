class AddActiveToWatchList < ActiveRecord::Migration
  def change
    add_column :watch_lists, :active, :boolean
  end
end
