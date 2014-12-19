class Tag < ActiveRecord::Base
  belongs_to :licserver
  #attr_accessible :title
  validates_uniqueness_of :title, :scope => :licserver_id 
end
