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
          puts "thisLine = #{thisLine}"
          puts "match_data = #{match_data}"
          returnArray.last[:current] = match_data[:lic_inuse]
          returnArray.last[:max] = 0
        end

      end
    end

    returnArray
  end
end
