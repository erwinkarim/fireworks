class CreateAdsDepartments < ActiveRecord::Migration
  def change
    create_table :ads_departments do |t|
      t.string :name

      t.timestamps
    end
  end
end
