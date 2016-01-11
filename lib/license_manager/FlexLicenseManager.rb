#interface for flex license manager to fireworks
require "license_manager/LicenseManager"

class FlexLicenseManager
  LMUTIL_PATH = "#{Rails.root}/lib/myplugin/lmutil"
  extend LicenseManager

  def self.dump *args
    default_options = { :licserver => "@localhost" , :feature => nil }
    options = default_options.merge args[0]

    `#{LMUTIL_PATH} lmstat -a -c #{options[:licserver]}`
  end

  # expected response:-
  # [ {
  #   :name, :current, :max,
  #   :users => [ {:user, user_id, :machine, :host_id, :port_id, :handle, :since, :lic_count }, { ... } ]
  #   (optional) :extra_info => [ {:version, :seats, :expire, :deamon }, { ... }]
  # }]
  def self.list_features *args
    default_options = { :licserver => "@localhost", :feature => nil, :extra_info => false}
    options = default_options.merge args[0]

    returnArray = Array.new
    output = `#{LMUTIL_PATH} lmstat -a -c #{options[:licserver]} -f #{options[:feature]} | grep -vi "error"`
    header = /Users.*/

    sections = output.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(/(?m)#{header}.*?(?=#{header})/)
    if sections.count == 0 then
      #handle if there's only 1 feature
      sections = output.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(/(?m)#{header}.*/)
    end

    # get user info
    sections.each do |section|
      feature_line = section.lines.grep(/Users/).first

      #get feature name, and current usage
      unless feature_line.nil?
        #create new headers where necessary
        feature_name = feature_line.split(" ")[2].gsub(/:/, '')

        returnArray << {
          :name => feature_name, :current => feature_line.split[10], :max => feature_line.split[5]
        }
      end

      #get user list in each feature
      user_lines = section.lines.grep(/start/)
      unless user_lines.nil? || user_lines.empty?
        returnArray.last[:users] = Array.new

        #get users
        user_lines.each do |user_line|
          user_line_array = user_line.scan(/\S+/)
          version_index = user_line_array.index{ |x| x =~ /\(\S+\)/ }
          correction = 0

          #the version keyword is not in the string, so use the (server/port) keywork instead
          if version_index.nil? then
            version_index = user_line_array.index{ |x| x =~ /\(\S+/ }
            correction = -1
          end

          returnArray.last[:users] << {
            :user => user_line_array[0..zero_if_negative(version_index-3)].join(" "),
            :user_id => User.find_by_name( user_line_array[0..version_index-3].join(" ") ),
            :machine => user_line_array[version_index-2],
            :host_id => user_line_array[version_index+correction+1].split('/')[0].gsub(/\(/, ''),
            :port_id => user_line_array[version_index+correction+1].split('/')[1],
            :handle => user_line_array[version_index+correction+2].gsub(/\)/, '').gsub(/,/, ''),
            :since => Time.parse(user_line_array[version_index+correction+4..version_index+correction+6].reverse.join(" ")).to_datetime ,
            :lic_count => user_line_array[version_index+correction+7]
          }
        end
      end
    end

    #grab extra info like vendor deamon name, and expiration date
    if options[:extra_info] then
      grep_option = "[0-9]-[[:alpha:]][[:alpha:]][[:alpha:]]-[0-9]"
      output = `#{LMUTIL_PATH} lmstat -i -c #{options[:licserver]} | grep #{grep_option}`

      output.each_line do |thisline|
        thislineS = thisline.split
        #matchup w/ the returnArray

        selected_feature = returnArray.select{ |x| x[:name] =~ /(#{thislineS[0]})/}.first
        unless selected_feature.nil?
          if selected_feature[:extra_info].nil? then
            selected_feature[:extra_info] = Array.new
          end

          selected_feature[:extra_info] << {
            :version => thislineS[1], :seats => thislineS[2], :expire => Date.parse(thislineS[3]),
            :deamon => thislineS[4]
          }

          temp = {:feature => thislineS[0], :version => thislineS[1], :seats => thislineS[2],
            :expire => Date.parse(thislineS[3]), :deamon => thislineS[4] }
          returnArray.push temp
        end
      end

    end

    return returnArray
  end

  def self.kill_user *args
    default_options = {:licserver => "localhost", :feature_id => 0, :host_id => 0 , :port_id => 0 , :handle => 0}
    options = deafult_options.merge(args[0])

    `#{LMUTIL_PATH} lmutil lmremove -c #{options[:licserver]} -h #{options[:feature_id]} #{options[:host_id]} #{options[:port_id]} #{options[:handle]}`
  end

	# return zero if the number is negatie
	def self.zero_if_negative the_number
		return the_number < 0 ? 0 : the_number
	end
end
