class Machine < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name
  has_many :machine_features
  has_many :features, :through => :machine_features
end
