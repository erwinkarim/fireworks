module GenerateReport
  @queue = :default
  def self.perform
    ReportSchedule.where(:scheduled => true).each do |rs|
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
    end #each
  end
end
