class AddTimescopeToReportSchedule < ActiveRecord::Migration
  def change
    add_column :report_schedules, :time_scope, :string
  end
end
