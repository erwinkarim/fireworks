module CollectData
  @queue = :default
  def self.perform
    Licserver.where{ to_delete.eq false }.each do |lic|
      lic.update_features
    end
  end
end
