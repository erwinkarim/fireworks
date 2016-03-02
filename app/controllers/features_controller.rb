class FeaturesController < ApplicationController
	before_filter :authenticate_ads_user!, :only => [ :kill ]

  # GET    /licservers/:licserver_id/features/:id(.:format)
  def show
    respond_to do |format|
			format.html {
				@licserver = Licserver.find(params[:licserver_id])
			}
			format.json {
				feature = FeatureHeader.where(:licserver_id => params[:licserver_id], :name => params[:id]).first
				render :json => feature
			}
			format.template
    end
  end

	#update settings for the feature
	# PATCH  /licservers/:licserver_id/features/:id
	def update
		#find the feature header
		feature = FeatureHeader.where(:licserver_id => params[:licserver_id], :name => params[:id]).first

		if feature.nil? then
			render :nothign => true, :status => :not_found
			return
		else
			#update the feature
			if params.has_key? :'enforce-uniq' then
				feature.update_attribute(:uniq_users, true)
			else
				feature.update_attribute(:uniq_users, false)
			end
			render :nothing => true, :status => :ok
		end
	end

	# DELETE /licservers/:licserver_id/features/:feature_id/user(.:format)
  def kill_user
    #kill user here
		licserver = Licserver.find(params[:licserver_id])
    @output = licserver.kill_user(
			{ :feature => params[:feature_id], :host => params[:host_id], :port => params[:port_id], :handle => params[:handle]}
		)

    respond_to do |format|
			format.js
    end
  end

	#nuke users
	# DELETE /licservers/:licserver_id/features/:feature_id/users(.:format)
	def kill_users
		licserver = Licserver.find(params[:licserver_id])
		#get users list
		users = licserver.current_users( params[:feature_id])

		#mass kill them
		users.each do |user|
			licserver.kill_user({ :feature => params[:feature_id],
				:host => user[:host_id], :port => user[:port_id], :handle => user[:handle]})
		end

		respond_to do |format|
				format.js {
					render :nothing => true, :status => :ok
				}
		end
	end

	def users
		@users = Licserver.find(params[:licserver_id]).current_users(params[:feature_id])
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

	# GET    /licservers/:licserver_id/features/:feature_id/histogram_data
	def histogram_data
		licserver = Licserver.find(params[:licserver_id])

		office_hours = licserver.usage_histogram_data(params[:feature_id])
		all_hours = licserver.usage_histogram_data(params[:feature_id], false)

		respond_to do |format|
			format.json { render :json => { :office => office_hours, :all => all_hours }  }
		end
	end

	# licserver_feature_usage_report_data
	#  GET    /licservers/:licserver_id/features/:feature_id/usage_report_data(.:format)
	def usage_report_data
		data = Licserver.find(params[:licserver_id]).usage_report_data( params[:feature_id] )

		respond_to do |format|
			format.json { render :json => data }
		end
	end

	def feature_header_params
		params.require(:feature_header).permit( :name, :licserver_id, :feature_id, :last_seen )
	end

	def feature_params
		params.require(:feature).permit( :current, :max, :name, :licserver_id )
	end
end
