module LinkUserToAD
  @queue = :default
  def self.perform
    UserTracking.link_user_to_ad ENV['ads_user'], ENV['ads_password']
  end
end
