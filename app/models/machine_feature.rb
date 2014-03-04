class MachineFeature < ActiveRecord::Base
  belongs_to :machine
  belongs_to :feature
  attr_accessible :machine_id, :feature_id
end
