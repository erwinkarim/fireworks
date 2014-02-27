scheduler = Rufus::Scheduler.start_new

scheduler.every("11m") do
  #in future send tasks to a task-manager
  @licserver = Licserver.all
  @licserver.each do |lic|
    Feature.update_features(lic.id)
  end 
end 

# remove errenous featurse everyday at 10
# every day of the week at 22:00 (10pm)
scheduler.cron('0 22 * * *') do
    @licserver = Licserver.all
    @licserver.each do |lic|
      Feature.remove_old_f(lic.id)
    end
end

# check and kill idle/unregistered users (if setted)
scheduler.every("23m") do
  @licserver = Licserver.all
  @licserver.each do |lic|
    if lic.monitor_idle then
      #go through every feature and kill users
      Feature.check_idle_users lic.id
    end
  end
end

#check if any reports needs to be generated
scheduler.every("2m") do
end
