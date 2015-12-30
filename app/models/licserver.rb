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
  end

  #get features listing, version, seat count expiration date
  def self.get_features_demise licserver_id
    @licserver = Licserver.find(licserver_id)
    @features = @licserver.features.where("created_at > ?", @licserver.features.last.created_at - 1.minute)
    full_address = @licserver.port.to_s + "@" + @licserver.server
    @lmutilOutput = `#{Rails.root.to_s}/lib/myplugin/lmutil lmstat -i -c #{full_address} | grep [0-9][0-9]-[[:alpha:]]`

    returnArray = Array.new
    @lmutilOutput.each_line do |thisline|
      thislineS = thisline.split
      temp = {:feature => thislineS[0], :version => thislineS[1], :seats => thislineS[2],
        :expire => Date.parse(thislineS[3]), :deamon => thislineS[4] }
      returnArray.push temp
    end

    #:feature might be truncated, so help append the feature name
    @lmutilOutput = `#{Rails.root.to_s}/lib/myplugin/lmutil lmstat -f -c #{full_address} | grep "Users of" | gawk '{ print gensub(":", "", "G", $3) } ' `
    featuresArray = Array.new
    @lmutilOutput.each_line do |thisline|
      featuresArray.push thisline.strip
    end

    featuresArray.each do |thisF|
      returnArray.collect { |thisA|
        if(thisF.index(thisA[:feature]) == 0) then
          thisA[:feature] = thisF
        end
      }
    end

    return returnArray
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
    @fullname = licserver.port.to_s + '@' + licserver.server

    Rails.logger.info "getting stats for #{@fullname} "
    #new way to generate features,users and machine  data
    output = `#{Rails.root}/lib/myplugin/lmutil lmstat -a -c #{@fullname} | grep -vi "error"`
    header = /Users.*/

    #split the output into headers of "Users of <feature name>...."
    #sections = output.scan(/(?m)#{header}.*?(?=#{header})|\Z/)
    sections = output.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(/(?m)#{header}.*?(?=#{header})/)
    if sections.count == 0 then
      #handle if there's only 1 feature
      sections = output.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(/(?m)#{header}.*/)
    end
    sections.each do |section|
      feature_line = section.lines.grep(/Users/).first
      unless feature_line.nil?
        #create new headers where necessary
        feature_name = feature_line.split(" ")[2].gsub(/:/, '')
        #Rails.logger.debug "Getting feature stats for #{feature_name}"
        if ( licserver.feature_headers.where(:name => feature_name ).empty? ) then
          licserver.feature_headers.create( :name => feature_name, :last_seen => DateTime.now ).save!
        end

        feature = licserver.feature_headers.where(:name => feature_name).first.features.create(
          :name => feature_name, :current => feature_line.split[10], :max => feature_line.split[5],
          :licserver_id => licserver.id
        )
        licserver.feature_headers.where(:name => feature_name).first.update_attribute(:last_seen, DateTime.now)
        feature.save!
      end

      #collect user info
      user_lines = section.lines.grep(/start/)
      unless user_lines.nil? || user_lines.empty?
        user_lines.each do |user_line|
          user_line_array = user_line.scan(/\S+/)
          version_index = user_line_array.index{ |x| x =~ /\(\S+\)/ }

          #the version keyword is not in the string, so use the (server/port) keywork instead
          if version_index.nil? then
            version_index = user_line_array.index{ |x| x =~ /\(\S+/ }
          end

          User.generate_features_data(
            user_line_array[0..zero_if_negative(version_index-3)].join(" "), user_line_array[version_index-2] , feature.id
          )
        end
      end
    end
  end

  def current_users( features_id )
    licserver = self

    @fullname = licserver.port.to_s + '@' + licserver.server

    output = `#{Rails.root}/lib/myplugin/lmutil lmstat -a -c #{@fullname} -f #{features_id} | gawk '/start/ { print $0 }'`

    users = []
    output.each_line do |line|
      correction = 0
      line_array = line.scan(/\S+/)
      version_index = line_array.index{ |x| x =~ /\(\S+\)/ }
      if version_index.nil? then
        version_index = line_array.index{ |x| x =~ /\(\S+/ }
        correction = -1
      end
      #need to handle cases where the version keyword is not there
      users << { :user => line_array[0..zero_if_negative(version_index-3)].join(" "),
        :user_id => User.find_by_name( line_array[0..version_index-3].join(" ") ),
        :machine => line_array[version_index-2],
        :host_id => line_array[version_index+correction+1].split('/')[0].gsub(/\(/, ''),
        :port_id => line_array[version_index+correction+1].split('/')[1],
        :handle => line_array[version_index+correction+2].gsub(/\)/, '').gsub(/,/, ''),
        :since => Time.parse(line_array[version_index+correction+4..version_index+correction+6].reverse.join(" ")).to_datetime ,
        :lic_count => line_array[version_index+correction+7]
      }
    end

    return users
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
    # get list of current users
    current_users = self.current_users(feature_name)

    mailing_list = Array.new

    current_users.each do |user|
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
