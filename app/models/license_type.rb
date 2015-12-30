class LicenseType < ActiveRecord::Base
  validates_uniqueness_of :name
  belongs_to :licserver
end
