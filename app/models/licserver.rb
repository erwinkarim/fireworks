require "license_manager/FlexLicenseManager"
require "license_manager/RepriseLicenseManager"

class Licserver < ActiveRecord::Base
  #attr_accessible :port, :server, :to_delete, :monitor_idle
  validates :server, :presence => true
  validates :license_type_id, :presence => true
  validates_uniqueness_of :server, :scope => :port
  validates :port, :inclusion => 1..65535, :allow_nil => true
  has_many :tags, :dependent => :destroy
  has_many :feature_headers, :dependent => :destroy
  has_many :features, :through => :feature_headers
  belongs_to :license_type
  after_initialize :init

  def init
    self.monitor_idle ||= false
    self.to_delete ||= false
    self.license_type_id ||= LicenseType.first.id
  end

  #get features listing, version, seat count expiration date
  def get_features_demise
    results = eval(self.license_type.name).list_features(:licserver => self.get_port_at_server, :extra_info => true)

    results.select{ |x| !x[:extra_info].nil? }.map{|x| x[:extra_info].map{ |y|
        { :feature => x[:name], :version => y[:version], :seats => y[:seats], :expire => y[:expire], :deamon => y[:deamon] }
      }
    }.flatten
  end

  def get_port_at_server
    return self.port.to_s + '@' + self.server
  end

  #get the trendiest, most heavily used features
  def self.get_trendy options = {}

    default_options = {
      :limit => 20, :since => 1.week.ago
    }
    default_options =  default_options.merge options

    trends = Licserver.joins{features}.where{
      features.created_at.gt default_options[:since]
    }.select{
      'licservers.id, licservers.port, licservers.server, features.name,
      sum(features."CURRENT") as total_current, sum(features.max) as total_max'
    }.group(
      'licservers.id, licservers.port, licservers.server, features.name'
    ).having('count(features.max) > 100').map{|x|
      {
        :id => x.id, :port => x.port, :server => x.server,
        :name => x.name, :usage => x.total_current/x.total_max.to_f
      }
    }.sort_by{ |e| -e[:usage] }

    return trends
  end

	#to update tags listings, add new one, remove old one, retains that doesn't change value
	#arguments:-
	# new_tag_listings		a list of tags seperated by space
	def update_tag_list new_tag_listings
		new_tags = new_tag_listings.split(' ')
		#drop tags that is not in the new list
		dropped_tags = self.tags.map{ |x| x.title } - new_tags
		self.tags.where{ title.in dropped_tags }.destroy_all

		#add tags that is in the new list
		(new_tags - self.tags.map{|x| x.title } ).each{ |x| self.tags.create( :title => x ) }
	end

  def update_features
    # suppress sql output for a while
    ActiveRecord::Base.logger = nil

    #update features here
    licserver = self

    Rails.logger.info "getting stats for #{self.get_port_at_server} "
    Rails.logger.info "license type is #{self.license_type.name}"

    #get the results form appropiate module
    results = eval(self.license_type.name).list_features({:licserver => licserver.get_port_at_server })

    results.each do |result_line|
      #update feature info
      if ( licserver.feature_headers.where(:name => result_line[:name] ).empty? ) then
        licserver.feature_headers.create( :name => result_line[:name], :last_seen => DateTime.now ).save!
      end

      feature = licserver.feature_headers.where(:name => result_line[:name]).first.features.create(
        :name => result_line[:name], :current => result_line[:current], :max => result_line[:max],
        :licserver_id => licserver.id
      )
      licserver.feature_headers.where(:name => result_line[:name]).first.update_attribute(:last_seen, DateTime.now)
      feature.save!

      #update people who are using this feature
      unless result_line[:users].nil?
        result_line[:users].each do |user|
          User.generate_features_data(
            user[:user], user[:machine], feature.id
          )
        end
      end
    end

  end

  def current_users( features_name )
    licserver = self

    eval(licserver.license_type.name).list_features(
      { :licserver => licserver.get_port_at_server, :feature => features_name }
    ).first[:users]
  end

  def kill_dup_users feature_name
    #get licserver full name
    licserver = self
    licserver_name = [licserver.port, licserver.server].join('@')

    #get list of current users
    current_users = self.current_users(feature_name)
    current_users = current_users - current_users.select{ |x| x[:user_id].nil? }
    current_users = current_users - current_users.select{ |x| x[:user_id].uniq_exempt == true }

    #get dup users
    dup_list = current_users.select{ |e| current_users.count{ |x| x[:user] == e[:user] } > 1 }

    #kill the latest sessions
    dup_list.each.with_index do |e,i|
      if i != 0 && e[:user] == dup_list[i-1][:user] then
        Rails.logger.info "#{ DateTime.now.strftime } : Killing #{ e[:user] }@#{e[:machine]}, #{ e[:since] } for holding multiple #{feature_name} seats"
        #self.kill_user(licserver_id, feature_name, e[:host_id], e[:port_id], e[:handle])
        output = `#{Rails.root}/lib/myplugin/lmutil lmremove -c #{licserver_name} -h #{feature_name} #{e[:host_id] } #{e[:port_id]} #{e[:handle]}`
      end
    end
  end

  def get_mailing_list feature_name
    mailing_list = Array.new

    # get list of current users
    self.current_users.select{|x| !x[:user_id].nil? }.each do |user|
      if !user[:user_id].ads_user.nil? then
        mailing_list << user[:user_id].ads_user.email
      end
    end

    return mailing_list
  end

  def check_idle_users
    licserver = self
    @fullname = licserver.port.to_s + '@' + licserver.server

    puts "Kill Idle users for " + @fullname
    #get list of current users and return a kill list
    lm_output =`#{Rails.root}/lib/myplugin/lmutil lmstat -a -c #{@fullname} | gawk '/Users/ { print $0 } /start/ { print $1, $2, $5, $6, $8, $9, $10 }'`

    output = Array.new
    feature = String.new
    lm_output.each_line do | line |
      if line.include? 'Users of' then
        feature = line.split[2].gsub(':', '')
        #next
      else
        lineSplit = line.split
        user = lineSplit[0]
        client_host = lineSplit[1]
        start_time = DateTime.parse(lineSplit[4..6].join(' ').sub(',','')+DateTime.now.zone)
        @idleUser =  IdleUser.where('user = ? and hostname =?', user, client_host).first

        #check idle parameters
        if (@idleUser.nil?  && start_time < 2.hours.ago) ||
          (!@idleUser.nil? && @idleUser.idle.to_i / 1000 > 60*30) ||
          ( !@idleUser.nil? && @idleUser.updated_at < 2.hours.ago) then
            #user not registered and has been using for more than 2 hours
            #user is registered and has been idle for more that 30 minutes
            #user is registered and has not check in more than 2 hours
            server_host = lineSplit[2].split('/')[0].sub('(', '')
            port_host = lineSplit[2].split('/')[1].to_i
            server_handle = lineSplit[3].to_i

            temp = { :feature => feature, :user => user, :client_host => client_host, :server_host => server_host,
              :port_host => port_host, :server_handle => server_handle , :start_time => start_time}

            output.push temp
        end #@idleUser.nil?
      end #line.includes?
    end #each_line

    #kill them
    output.each do | thisUser |
      Feature.kill_user @fullname, thisUser[:feature], thisUser[:server_host],
        thisUser[:port_host], thisUser[:server_handle]
    end

    return output
  end

	# return zero if the number is negatie
	def zero_if_negative the_number
		return the_number < 0 ? 0 : the_number
	end
end
