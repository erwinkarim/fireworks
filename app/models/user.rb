class User < ActiveRecord::Base
  attr_accessible :name
  validates :name, :uniqueness => true, :presence => true
  has_many :machines, :dependent => :destroy

  def self.generate_features_data username, machine_name, feature_id
    #check if users has been created. if new, create else hone on that
    #puts "username = #{username} " 
    user = self.where(:name => username).first
    if user.nil? then
      user = self.create(:name => username)
      user.save!
    end 

    #from user, check if new machine or old machine, then user create or hone on that
    machine = user.machines.where(:name => machine_name).first
    if machine.nil? then
      machine = user.machines.create(:name => machine_name)
      machine.save!
    end
    
    #finally, connect that to feature that is being used
    machine.machine_features.create(:feature_id => feature_id).save! 

  end
end
