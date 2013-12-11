class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :title
      t.references :licserver

      t.timestamps
    end
    add_index :tags, :licserver_id
  end
end
