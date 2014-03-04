class AddScheduledToReportSchedule < ActiveRecord::Migration
  def change
    add_column :report_schedules, :scheduled, :boolean
  end
end
