class Tag < ActiveRecord::Base
  belongs_to :licserver
  #attr_accessible :title
  validates_uniqueness_of :title, :scope => :licserver_id

  # returns as [ { :title, :licservers => [licserver1, licserver2, ... that are connected w/ title ] } ]
  def self.search( query = "")
    #find title w/ search term
    title_result = self.where{ upper(title) =~ "%#{query.upcase}%"}

    #find licserver w/ search term
    licserver_result = Tag.where(:licserver_id => Licserver.where{ upper(server) =~ "%#{query.upcase}%"}.map{ |x| x.id } )

    #find modules w/ search term
    module_result = Tag.where(:licserver_id => FeatureHeader.where{ (last_seen.gt 7.days.ago) & ( upper(name) =~ "%#{query.upcase}%") }.map{ |x| x.licserver_id}.uniq )

    #collase and return w/ the search results
    final_results = Array.new
    (title_result + licserver_result + module_result).uniq.each do |e|
      #pump into each
      if final_results.select{|x| x[:title] == e.title }.empty? then
        #new index
        final_results << { :title => e.title, :licservers => [ Licserver.find(e.licserver) ]}
      else
        #existing index, check if liceserver is already there
        first_result = final_results.select{ |x| x[:title] == e.title }.first
        puts "first_result = #{first_result.inspect}"
        if first_result[:licservers].select{ |y| y.id == e.licserver_id }.empty? then
          first_result[:licservers] << Licserver.find(e.licserver_id)
        end
      end
    end

    return final_results

  end
end
