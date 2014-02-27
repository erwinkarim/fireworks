class MachineFeatureData < ActiveRecord::Base
  belongs_to :machine
  belongs_to :feature
  # attr_accessible :title, :body
end
