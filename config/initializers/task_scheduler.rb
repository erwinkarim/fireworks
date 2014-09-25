scheduler = Rufus::Scheduler.new

scheduler.every("11m") do
  #in future send tasks to a task-manager
  @licserver = Licserver.where{ to_delete.eq false }
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
  @licserver = Licserver.where{ to_delete.eq false }
  @licserver.each do |lic|
    if lic.monitor_idle then
      #go through every feature and kill users
      Feature.check_idle_users lic.id
    end
  end
end

#check if any reports needs to be generated
scheduler.every("5m") do
  ReportSchedule.all.each do |rs|
    if rs.scheduled? then
      if rs.reports.last.nil? then
        rs.generate_report
      else
        case rs.time_scope
        when 'Yesterday'
          time_limit = 1.day.ago
        when 'Last Week'
          time_limit = 1.week.ago
        else
          #defaults to last month
          time_limit = 1.month.ago
        end
        if rs.reports.last.created_at < time_limit then
          rs.generate_report
        end
      end
    end
  end #each
end
