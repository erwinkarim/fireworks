module CheckIdleUsers
  @queue = :default
  def self.perform
    Licserver.where{ to_delete.eq false}.each do |lic|
      if lic.monitor_idle then
        #go through every feature and kill users
        Feature.check_idle_users lic.id
      end
    end
  end
end
