class FeatureHeader < ActiveRecord::Base
  belongs_to :licserver
  has_many :features
  validates_uniqueness_of :name, :scope => :licserver_id 
  #attr_accessible :name, :licserver_id, :feature_id, :last_seen
end
