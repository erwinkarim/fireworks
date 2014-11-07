class WatchList < ActiveRecord::Base
  belongs_to :ads_user
  attr_accessible :model_id, :model_type, :note
end
