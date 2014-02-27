class User < ActiveRecord::Base
  attr_accessible :name
  validates :name, :uniqueness => true, :presence => true
  has_many :machines, :dependent => :destroy
end
