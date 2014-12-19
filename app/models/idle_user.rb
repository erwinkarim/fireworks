class IdleUser < ActiveRecord::Base
  #attr_accessible :hostname, :idle, :user
  validates :hostname, :presence => true;
  validates :idle, :presence => true;
  validates :user, :presence => true;
  validates_uniqueness_of :user, :scope=> :hostname
end
