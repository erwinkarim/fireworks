class AddTitleToReportSchedule < ActiveRecord::Migration
  def change
    add_column :report_schedules, :title, :string
  end
end
