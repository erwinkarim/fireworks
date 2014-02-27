class Machine < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name
  has_many :machine_features_data
end
