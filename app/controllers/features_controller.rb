class FeaturesController < ApplicationController
	before_filter :authenticate_ads_user!, :only => [ :kill ]
	
  def index
    @licserver = Licserver.find(params[:licserver_id])
    if @licserver.features.count > 0 then
      #@features = @licserver.features.where("created_at > ?", Licserver.find(params[:licserver_id]).features.last.created_at - 1.minute)
      @features = @licserver.feature_headers.where{ last_seen.gt 1.day.ago }
    else 
      @features = nil
    end

    #get features info
    if !@features.nil? then
      @features_info = Licserver.get_features_demise params[:licserver_id]
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render xml: @features }
      format.json { render json: @features }
    end
  end

  # GET    /licservers/:licserver_id/features/list(.:format)
  # list all features that params[:licserver_id] recently have
  def list
    #in the future, would retrive from FeaturesSummary table which detect features headers instead of raw data as current format
    @licserver = Licserver.find(params[:licserver_id])
    #@features = @licserver.features.order('created_at desc').limit(200).pluck(:name).uniq.map{ |item| {:name => item}}
    #@features = @licserver.feature_headers.where{ last_seen.gt 1.day.ago }.map{ |item| { :name => item.name } }
    @features = @licserver.feature_headers.where{ last_seen.gt 1.week.ago }.map{ |item| { :name => item.name, :id => item.id } }
    
    respond_to do |format|
      format.html { render :partial => 'list', :locals => { :features => @features, :licserver => @licserver, :watched => @watched } }
      format.json{ render json: @features }
    end
  end

  # GET    /licservers/:licserver_id/features/:id(.:format) 
  def show

    @licserver = Licserver.find(params[:licserver_id])
    @feature = @licserver.feature_headers.where{ last_seen.gt 1.week.ago }.where(:name => params[:id]).first
    if ads_user_signed_in? then
      @watched = current_ads_user.watch_lists.where(:model_type => 'FeatureHeader', :model_id => @feature.id ).first
    end
    #@users = Feature.current_users(params[:licserver_id], params[:id])

    respond_to do |format|
      format.html 
      format.json
    end
  end
  
  # GET    /licservers/:licserver_id/features/:feature_id/monthly(.:format)
  def monthly
    if params[:office_hours] == 'yes' then 
      office_hours_only = true
    else
      office_hours_only = false
    end
 
    @features = Feature.generate_monthly_stats( params[:licserver_id], 
      params[:feature_id], office_hours_only).sort.map {|thisf| [ thisf[0], thisf[1] ] } 
    
    respond_to do |format|
      format.xml { render xml: @features }
      format.json { render json: @features }
    end
  end

  def kill
    #kill user here
    @licserver = Licserver.find(params[:licserver_id])
    @fullname = @licserver.port.to_s + '@' + @licserver.server
    @output = Feature.kill_user(@fullname, params[:feature_id], params[:host_id], params[:port_id], params[:handle])

    respond_to do |format|
      format.html { redirect_to :back } 
      format.xml { render :text => 'successful' }
			format.js
    end
  end

  # GET    /licservers/:licserver_id/features/:feature_id/get_data(.:format)
  # generate data for features params[:feature_id] from licserver params[:licserver_id]
  # will return 10000 data points at at time beginning from start_id or Feature.last.id and the previous
  # 100 points in the format of 
  #
  #   [ { name:current, data:[ [created_at*1000, x1], ...[created_at*1000, xN] ] }, 
  #     { name:max, data[ [created_at*1000, x1], ...[created_at*1000, xN] ] } ] 
  #
  # options:
  # start_id      take data point with this start id and the previous 10000 data points
  def get_data
    @licserver = Licserver.find(params[:licserver_id])
    feature_name = params[:feature_id]
    if params.has_key? :start_id then
      start_id = params[:start_id].to_i - 1
    else
      start_id = Feature.last.id
    end
    @features = @licserver.features.where{ (features.id.lteq start_id) & (features.name.eq feature_name) }.
      limit(2000).order('features.id desc')
    output = [ { :name => 'current' , :data => [] }, { :name => 'max', :data => [] } ]
    @features.each do |x|
      output[0][:data] << [x.created_at.to_i*1000, x.current, x.id]
      output[1][:data] << [x.created_at.to_i*1000, x.max]
    end

    respond_to do |format|
      format.json { render :json => { :last_id => @features.empty? ? 0 : @features.min.id, :data => output  } }
    end
  end

  #  GET    /licservers/:licserver_id/features/:feature_id/data_dump
  #  almost the same as get_data, but instead dump everything (can be expensive)
  def data_dump
    @licserver = Licserver.find(params[:licserver_id])
    feature_name = params[:feature_id]

    @features = @licserver.features.where{ (features.name.eq feature_name) }.order('features.created_at asc')
    output = [ { :name => 'current' , :data => [] }, { :name => 'max', :data => [] } ]
    @features.each do |x|
      output[0][:data] << [x.created_at.to_i*1000, x.current]
      output[1][:data] << [x.created_at.to_i*1000, x.max]
    end

    respond_to do |format|
      format.json { render :json => { :last_id => @features.empty? ? 0 : @features.min.id, :data => output  } }
      format.xml { send_data @features.to_xml, :filename => params[:feature_id].to_s + '.xml' }
      format.csv { }
    end
  end


  #  GET    /licservers/:licserver_id/features/:feature_id/users(.:format)
  # get a list of current users from params[:licserver_id] using features params[:feature_id] 
  def users
    @users = Feature.current_users(params[:licserver_id].to_i, params[:feature_id]) 

    respond_to do |format|
      format.json{ render :json => @users }
      format.html{ render :partial => 'users', 
        :locals => { :users => @users, :licserver => params[:licserver_id], :feature => params[:feature_id]  } 
      }
    end
  end

  # GET    /licservers/:licserver_id/features/:feature_id/historical_users
  # get a list of users based on historical data (time value on the graph since can't get id value from point info)
  # options:-
  #   time_id   required. the time (x) value that you get from the graph when clicked on the point
  def historical_users
      selected_time = Time.at( params[:time_id].to_i / 1000  ) 
      time_range = (selected_time - 5.minutes)..(selected_time + 5.minutes)
      licserver = Licserver.find(params[:licserver_id])
      #feature = params[:feature_id] 
      feature = licserver.feature_headers.where(:name => params[:feature_id]).first.features.where{
        created_at.in time_range
      }.first
      if feature.nil? then
        @users = []
      else
        @users =  
          Machine.where{ 
            id.in MachineFeature.where( :feature_id => feature.id ).map{ |x| x.machine_id } 
          }.joins{ user }.select{ 'users.id as user_id, users.name as username, machines.name as machinename' }.map{
            |x| { :user_id => x.user_id, :username => x.username, :machinename => x.machinename }
          }
      end

    respond_to do |format|
      format.html{ render :partial => 'historical_users', :locals => { :users => @users, :feature => feature, :selected_time => (feature.nil? ? selected_time : feature.created_at) } }
    end
  end
end
