class ReportSchedule < ActiveRecord::Base
  attr_accessible :monitored_obj, :schedule, :title, :time_scope, :scheduled
  validates :title, :presence => true, :uniqueness => true
  has_many :reports, :dependent => :destroy
  TIME_SCOPE = { :yesterday => 'Yesterday', :last_week => 'Last Week', :last_month => 'Last Month' }

  #generate a new report based on :monitored_obj, and :time_scope
  def generate_report report_id = nil
    if self.time_scope == 'Yesterday' then
        date_range = 1.day.ago.at_beginning_of_day..DateTime.now.at_beginning_of_day
    elsif self.time_scope == 'Last Week' then
        date_range = 1.week.ago.at_beginning_of_week..1.week.ago.at_end_of_week
    else
        date_range = 1.month.ago.at_beginning_of_month..1.month.ago.at_end_of_month
    end
    
    report_text = Hash.new

    YAML::load(self.monitored_obj).keys.each do |licserver_id|
      server_report = Hash.new

      #generate stats for all hours
      error_margin = Licserver.find(licserver_id.to_s).features.where{
          (created_at.in date_range)
      }.count.to_f * 0.01
      all_hours_dump = Licserver.find(licserver_id.to_s.to_i).features.where{
          (created_at.in date_range)
        }.select{ [name, max, sum(current).as(total_current), sum(max).as(total_max), count(max).as(max_count) ] }.
        group( :name, :max ).
        having{ count(name) > error_margin }.
        map{ |x| [ x.name, x.max, x.total_current, x.total_max, x.max_count ]  }
      server_report  = server_report.merge({ :all_hours => all_hours_dump } )

      #generate stats for office hours
      error_margin = Licserver.find(licserver_id.to_s).features.where{
          ( to_char( created_at, 'HH24:MI:SS') > '01:00:00' ) & 
          ( to_char( created_at, 'HH24:MI:SS' ) < '10:00:00' ) & 
          ( to_char( created_at, 'D') != 1 ) & ( to_char( created_at, 'D' ) != 7 ) & 
          (created_at.in date_range)
      }.count.to_f * 0.01
      office_hours_dump = Licserver.find(licserver_id.to_s.to_i).features.where{
          # 0800 to 1700 malaysia time because data is stored in UTC
          ( to_char( created_at, 'HH24:MI:SS') > '01:00:00' ) & 
          ( to_char( created_at, 'HH24:MI:SS' ) < '10:00:00' ) & 
          ( to_char( created_at, 'D') != 1 ) & ( to_char( created_at, 'D' ) != 7 ) & 
          (created_at.in date_range)
        }.select{ [name, max, sum(current).as(total_current), sum(max).as(total_max), count(max).as(max_count) ] }.
        group( :name, :max).
        having{ count(name) > error_margin }.
        map{ |x| [ x.name, x.max, x.total_current, x.total_max, x.max_count ]  }
      server_report = server_report.merge({ :office_hours => office_hours_dump } )

      report_text = report_text.merge( { licserver_id.to_sym => server_report } )
    end

    #build the actual reports
    if report_id.nil? then 
      new_report = self.reports.new( :title => self.title,
        :body => report_text,
        :start_date => date_range.first, :end_date => date_range.last
      )
    else
      #for some insane reason, generating a new report works, but updating a current report doesn't
      new_report = self.reports.find(report_id)
      new_report.update_attribute(:body ,nil)
      new_report.save!
      new_report.update_attribute(:body ,report_text)
      new_report.save!
      new_report.update_attributes( :title => self.title,
        :start_date => date_range.first, :end_date => date_range.last
      )
    end

    new_report.save!

  end
end
