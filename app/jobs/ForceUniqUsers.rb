module ForceUniqUsers
  @queue = :default
  def self.perform
  	FeatureHeader.where(:uniq_users => true).each{|f| Licserver.find(f.licserver_id).kill_dup_users(f.name) }
  end
end
