class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :title
      t.text :body
      t.references :report_schedule

      t.timestamps
    end
    add_index :reports, :report_schedule_id
  end
end
