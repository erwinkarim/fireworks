#interface for flex license manager to fireworks
require "license_manager/LicenseManager"

class RepriseLicenseManager
  extend LicenseManager

  LMUTIL_PATH = "#{Rails.root}/lib/myplugin/rlmutil"

  def self.dump *args
    default_options = { :licserver => "@localhost" , :feature => nil }
    options = default_options.merge args[0]

    `#{LMUTIL_PATH} rlmstat -a -c #{options[:licserver]}`
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

    output = `#{LMUTIL_PATH} rlmstat -a -c #{options[:licserver]} `
    returnArray = Array.new

    licensePool = output.split(/------------------------/)[2].lines.delete_if{ |x| x == "\n" || x == "\t" }
    licensePool = licensePool[1..licensePool.length-1]

    licensePool.each do |thisLine|
      #see this is element is telling about a new module or info on the previous module

      if thisLine.index(/\t\t/).nil? then
        #talking about new feature
        returnArray << { :name => thisLine.strip.split.first}
      else
        #check if it counted or uncounted
        if thisLine.index(/^\t\tcount/) == 0 then
          #count: keyword detected.
          match_data = thisLine.match(/\t\tcount: (?<lic_count>\d+), # reservations: \d+, inuse: (?<lic_inuse>\d+)/)
          returnArray.last[:current] = match_data[:lic_inuse]
          returnArray.last[:max] = match_data[:lic_count]
        elsif thisLine.index(/^\t\tUNCOUNTED/) == 0 then
          #uncounted keyword detected
          match_data = thisLine.match(/\t\tUNCOUNTED, inuse: (?<lic_inuse>\d+)\n/)
          returnArray.last[:current] = match_data[:lic_inuse]
          returnArray.last[:max] = 0
        end

      end
    end

    userPool = output.split(/------------------------/)[3].lines.delete_if{ |x| x == "\n" || x == "\t" }
    userPool = userPool[1..userPool.length-1]

    #scan and sort user according to detected features
    userPool.each do |thisLine|
      match_data = thisLine.match(
        /(?<feature>\w+) v\d+.\d+: (?<username>[\w\d.]+)@(?<machinename>[\w-]+) \d+\/\d+ at (?<since>\d\d\/\d\d \d\d:\d\d)  \(handle: (?<handle>\w+)/)
      taggedFeature = returnArray.select{|x| x[:feature] = match_data[:feature]}.first
      if taggedFeature[:users].nil? then
        taggedFeature[:users] = Array.new
      end
      taggedFeature[:users] << {
        :user => match_data[:username],
        :user_id => User.find_by_name(match_data[:username]),
        :machine => match_data[:machinename],
        :host_id => nil,
        :handle => match_data[:handle],
        :since => Time.parse(match_data[:since]).to_datetime,
        :lic_count => nil
      }
    end

    returnArray
  end
end
