class AddPreSkewDataToFeature < ActiveRecord::Migration
  def change
    add_column :features, :pre_skew, :integer
  end
end
