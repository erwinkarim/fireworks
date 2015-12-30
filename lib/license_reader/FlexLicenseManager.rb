#interface for flex license manager to fireworks
require "license_reader/LicenseManager"

class FlexLicenseManager
  LMUTIL_PATH = "#{Rails.root}/lib/myplugin/lmutil"
  extend LicenseManager

  def self.dump *args
    default_options = { :licserver => "@localhost" , :feature => nil }
    options = default_options.merge args[0]

    `#{LMUTIL_PATH} lmstat -a -c #{options[:licserver]}`
  end

  def self.list_features *args
    default_options = { :licserver => "@localhost", :feature => nil, :extra_info => false}
    options = default_options.merge args[0]

    if options[:extra_info] then
      extra_info_option = "-i"
    end

    returnArray = Array.new
    output = `#{LMUTIL_PATH} lmstat -a -c #{options[:licserver]} #{extra_info_option} -f #{options[:feature]} | grep -vi "error"`
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

          #the version keyword is not in the string, so use the (server/port) keywork instead
          if version_index.nil? then
            version_index = user_line_array.index{ |x| x =~ /\(\S+/ }
          end

          returnArray.last[:users] << {
            :username => user_line_array[0..zero_if_negative(version_index-3)].join(" "),
            :machinename => user_line_array[version_index-2],
            :since => Time.parse(user_line_array[version_index+4..version_index+6].join(" ")).to_datetime
          }
        end
      end
    end

    #grab extra info like vendor deamon name, and expiration date
    if options[:extra_info] then
      grep_option = "[0-9]-[[:alpha:]][[:alpha:]][[:alpha:]]-[0-9]"
      #output = `#{LMUTIL_PATH} lmstat -i -c #{options[:licserver]} -f #{options[:feature]} | grep #{grep_option}`

      output.each_line do |thisline|
        thislineS = thisline.split
        #matchup w/ the returnArray

        selected_feature = returnArray.select{ |x| x[:name] =~ /(#{thislineS[0]})/}.first
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

    return returnArray
  end

	# return zero if the number is negatie
	def self.zero_if_negative the_number
		return the_number < 0 ? 0 : the_number
	end
end
