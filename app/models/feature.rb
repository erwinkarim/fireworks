class Feature < ActiveRecord::Base
  belongs_to :licserver
  belongs_to :feature_header
  #attr_accessible :current, :max, :name, :licserver_id
  has_many :machine_features
  has_many :machines, :through => :machine_features

  #update features
  def self.update_features(licserver_id)
		# suppress sql output for a while
		ActiveRecord::Base.logger = nil

    #update features here
    @licserver = Licserver.find(licserver_id)
    @fullname = @licserver.port.to_s + '@' + @licserver.server
    
		Rails.logger.info "getting stats for #{@fullname} "
    #new way to generate features,users and machine  data 
    output = `#{Rails.root}/lib/myplugin/lmutil lmstat -a -c #{@fullname} | grep -vi "error"`
    header = /Users.*/
  
    #split the output into headers of "Users of <feature name>...."
    #sections = output.scan(/(?m)#{header}.*?(?=#{header})|\Z/)
    sections = output.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(/(?m)#{header}.*?(?=#{header})|\Z/)
    sections.each do |section|
      feature_line = section.lines.grep(/Users/).first
      unless feature_line.nil? 
        #create new headers where necessary
        feature_name = feature_line.split(" ")[2].gsub(/:/, '')
        if ( @licserver.feature_headers.where(:name => feature_name ).empty? ) then
          @licserver.feature_headers.create( :name => feature_name, :last_seen => DateTime.now ).save!
        end
        
        feature = @licserver.feature_headers.where(:name => feature_name).first.features.create( 
          :name => feature_name, :current => feature_line.split[10], :max => feature_line.split[5],
          :licserver_id => @licserver.id
        )
        @licserver.feature_headers.where(:name => feature_name).first.update_attribute(:last_seen, DateTime.now)
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
						user_line_array[0..version_index-3].join(" "), user_line_array[version_index-2] , feature.id
					)
        end
      end
    end
    
  end

  #get list of current users
  def self.current_users(licserver_id,features_id)
    @licserver = Licserver.find(licserver_id)
    @fullname = @licserver.port.to_s + '@' + @licserver.server

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
      users << { :user => line_array[0..version_index-3].join(" "), 
				:user_id => User.find_by_name( line_array[0..version_index-3].join(" ") ),
				:machine => line_array[version_index-2],
        :host_id => line_array[version_index+correction+1].split('/')[0].gsub(/\(/, ''),
        :port_id => line_array[version_index+correction+1].split('/')[1],
				:handle => line_array[version_index+correction+2].gsub(/\)/, ''),
        :since => Time.parse(line_array[version_index+correction+4..version_index+correction+6].reverse.join(" ")).to_datetime , 
        :lic_count => line_array[version_index+correction+7] 
			}
    end

    return users
  end

  #kill users at will
  def self.kill_user(licserver_fullname, feature_id, host_id, port_id, handle)
    output = `#{Rails.root}/lib/myplugin/lmutil lmremove -c #{licserver_fullname} -h #{feature_id} #{host_id} #{port_id} #{handle}`

    return output
  end

  #maintaince function:-
  # - remove features that somehow got updated here through update_features function
  def self.remove_old_f(licserver_id)
    @licserver = Licserver.find(licserver_id) 
    @lostFeatures = @licserver.features.select("name, count(name) as l_count").group("name").having("count(name) = 1")

    #start killing them
    transaction do
      @lostFeatures.each do |lostF|
        @lostFList = @licserver.features.where("name = ?", lostF.name)
        @lostFList.each do |lostFListDetail|
          @fToDestory = @licserver.features.find(lostFListDetail.id)
          @fToDestory.destroy 
        end
      end 
    end
  end

  #maintainces function
  #build feature_headers line from features that don't have feature_header_id
  def self.build_feature_headers
    #rebuild 1000 at a time
    while Feature.where(:feature_header_id => nil).count != 0
      transaction do 
        Feature.where(:feature_header_id => nil).order('id desc').limit(5000).each do |f|
          #find the feature header, otherwise, built a new one
          fh = Licserver.find(f.licserver_id).feature_headers.where(:name => f.name).first
          if fh.nil? then
            fh = Licserver.find(f.licserver_id).feature_headers.new( :name => f.name)
            fh.save!
          end 

          f.update_attribute(:feature_header_id, fh.id)
        end
      end
    end
  end

  #find and kill idle users
  #return list of users that died
  def self.check_idle_users(licserver_id)
    @licserver = Licserver.find(licserver_id)
    @fullname = @licserver.port.to_s + '@' + @licserver.server
    
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

  #generate last 30 days stats
  def self.generate_monthly_stats(licserver_id, feature_id, office_hours)
  
    #generate default stats
      #features_list = Licserver.find(licserver_id).features.find(:all, 
      #  :conditions => { :name => feature_id, :created_at => 30.days.ago..DateTime.now })
      features_list = Licserver.find(licserver_id).features.where( :name => feature_id, :created_at => 30.days.ago..DateTime.now )

    if office_hours == true then
      #filter to office hours only
      #office hours is from 8am to 5pm
      features_list = features_list.select { |thisf| thisf.created_at.localtime.hour > 8 &&
        thisf.created_at.localtime.hour < 17 && thisf.created_at.localtime.wday != 0 &&
        thisf.created_at.localtime.wday != 6 }
    end

    #do the countings
    features_sorted = features_list.group_by{ |item| item.current }.reject{ |k,v| k.nil? || k[0].nil? }
    sum = 0
    features = features_sorted.inject(Hash.new(0)) { |h,e| h[e[0]] = e[1].count; h }.to_a.sort.map {
      |x| [ x[0], sum += x[1] ] 
    }

    return features
  end

  # generate csv from features of licserver_id bearing the feature_name
  def self.to_csv(licserver_id, feature_name)
    csv_string = String.new
  
  end
end
