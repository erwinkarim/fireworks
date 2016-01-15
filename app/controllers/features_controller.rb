class FeaturesController < ApplicationController
	before_filter :authenticate_ads_user!, :only => [ :kill ]

  # GET    /licservers/:licserver_id/features/:id(.:format)
  def show
    respond_to do |format|
			format.template
    end
  end

  def kill
    #kill user here
    @licserver = Licserver.find(params[:licserver_id])
    @fullname = @licserver.port.to_s + '@' + @licserver.server
    #@output = Feature.kill_user(@fullname, params[:feature_id], params[:host_id], params[:port_id], params[:handle])
    @output = Licserver.find(params[:licserver_id]).kill_user(
			{ :feature => params[:feature_id], :host => params[:host_id], :port => params[:port_id], :handle => params[:handle]}
		)


		Rails.logger.info "Killing #{params[:user]}/#{params[:feature_id]} by #{current_ads_user.login}"

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
		start_date = Feature.find(start_id).created_at
		data_points = params.has_key?(:start_id) ? 1000 : 200

		# we partition the features table by date, so include date so oracle will know which partition to go
    @features = @licserver.features.where{(features.created_at.lt start_date) & (features.id.lteq start_id) & (features.name.eq feature_name) }.
      limit(data_points).order('features.id desc')

    output = [ { :name => 'current' , :data => [] }, { :name => 'max', :data => [] } ]
    @features.each do |x|
      output[0][:data] << [x.created_at.to_i*1000, x.current, x.id]
      output[1][:data] << [x.created_at.to_i*1000, x.max]
    end

    respond_to do |format|
      format.json { render :json => { :last_id => @features.empty? ? 0 : @features.min.id, :data => output  } }
    end
  end

	def feature_header_params
		params.require(:feature_header).permit( :name, :licserver_id, :feature_id, :last_seen )
	end

	def feature_params
		params.require(:feature).permit( :current, :max, :name, :licserver_id )
	end
end
