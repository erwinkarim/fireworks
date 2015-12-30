module CheckIdleUsers
  @queue = :default
  def self.perform
    Licserver.where(:to_delete => false, :monitor_idle => true).each{ |x| x.check_idle_users }
  end
end
