class CreateReportSchedules < ActiveRecord::Migration
  def change
    create_table :report_schedules do |t|
      t.text :schedule
      t.text :monitored_obj

      t.timestamps
    end
  end
end
