class FeaturesController < ApplicationController
  def index
    @licserver = Licserver.find(params[:licserver_id])
    if @licserver.features.count > 0 then
      @features = @licserver.features.where("created_at > ?", Licserver.find(params[:licserver_id]).features.last.created_at - 1.minute)
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

  def show
    @licserver = Licserver.find(params[:licserver_id])
    @users = Feature.current_users(params[:licserver_id], params[:id])

    if params.has_key? :start_date then
      @start_date = DateTime.parse(params[:start_date])
    else
      @start_date = 30.years.ago
    end

    if params.has_key? :end_date then
      @end_date = DateTime.parse(params[:end_date])
    else
      @end_date = DateTime.now
    end

    respond_to do |format|
      format.html { 
        #@features = @licserver.features.where("name = ?", params[:id]).order(:created_at)
        feature_name = params[:id]
        @features = @licserver.features.where{ 
          ( name.eq feature_name ) & ( created_at.in 6.month.ago..DateTime.now) 
        }.order(:created_at)
        @feature = @features.last
        render :show 
      } # show.html.erb
      format.xml { 
        @features = @licserver.features.where("name = ? and created_at > ? and created_at < ?", params[:id],
          @start_date, @end_date)
        render xml: @features 
      }
      format.json { 
        @features = @licserver.features.where("name = ?", params[:id])
        render json: @features 
      }
    end
  end
  
  def monthly
    if params[:office_hours] == 'yes' then 
      office_hours_only = true
    else
      office_hours_only = false
    end
 
    @features = Feature.generate_monthly_stats( params[:licserver_id], 
      params[:feature_id], office_hours_only).sort.map {|thisf| { :current => thisf[0], :current_conut => thisf[1] } } 
    
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
    end
  end
end
