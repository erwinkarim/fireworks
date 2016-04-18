module LinkUserToAD
  @queue = :default
  def self.perform
    UserTracking.link_user_to_ad ENV['ADS_USER'], ENV['ADS_PASSWORD']
  end
end
