class Licserver < ActiveRecord::Base
  attr_accessible :port, :server, :to_delete
  validates :server, :presence => true
  validates_uniqueness_of :server, :scope => :port 
  validates :port, :inclusion => 1..65535, :allow_nil => true 
  has_many :tags, :dependent => :destroy 
  has_many :feature_headers, :dependent => :destroy
  has_many :features, :through => :feature_headers
  after_initialize :init

  def init
    #self.monitor_idle ||= false
    #self.to_delete ||= false
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

end
