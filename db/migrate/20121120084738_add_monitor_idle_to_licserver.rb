class AddMonitorIdleToLicserver < ActiveRecord::Migration
  def change
    add_column :licservers, :monitor_idle, :boolean
  end
end
