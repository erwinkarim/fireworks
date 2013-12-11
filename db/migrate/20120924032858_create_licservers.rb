class CreateLicservers < ActiveRecord::Migration
  def change
    create_table :licservers do |t|
      t.integer :port
      t.string :server
      t.timestamps
    end
    

  end
end
