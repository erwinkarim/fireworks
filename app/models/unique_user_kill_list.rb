class UniqueUserKillList < ActiveRecord::Base
  belongs_to :licserver

	def self.enforce_unique
		self.all.each do |e|
			Feature.kill_dup_users(e.licserver_id, e.feature_name)
		end
	end
end
