module ForceUniqUsers
  @queue = :default
  def self.perform
  	FeatureHeader.where(:uniq_users => true).each do |feature|
  		Feature.kill_dup_users(feature.licserver_id, feature.name)
  	end
  end
end
