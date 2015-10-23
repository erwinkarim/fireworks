module ResqueTest
  @queue = :default
  def self.perform
    Rails.logger.info "Test: #{DateTime.now}"
  end
end
