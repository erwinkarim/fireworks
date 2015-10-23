module CollectData
  @queue = :default
  def self.perform
    Licserver.where{ to_delete.eq false }.each do |lic|
      Feature.update_features(lic.id)
    end
  end
end
