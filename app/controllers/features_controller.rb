class FeaturesController < ApplicationController
	before_filter :authenticate_ads_user!, :only => [ :kill ]

  def index
    @licserver = Licserver.find(params[:licserver_id])
    if @licserver.feature_headers.count > 0 then
      @features = @licserver.feature_headers.where{ last_seen.gt 1.day.ago }
    else
      @features = nil
    end

    #get features info
    if !@features.nil? then
      @features_info = nil
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
    #in the future, would retrive from FeaturesSummary table which detect features headers
		#instead of raw data as current format
    @licserver = Licserver.find(params[:licserver_id])
    @features = @licserver.feature_headers.where{ last_seen.gt 1.week.ago }.map{
			|item| { :name => item.name, :id => item.id }
		}

    respond_to do |format|
      format.html {
				render :partial => 'list',
				:locals => { :features => @features, :licserver => @licserver, :watched => @watched }
			}
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
		@single_users = FeatureHeader.where(:licserver_id => @licserver.id, :name => @feature.name).first.uniq_users

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
    #@users = Feature.current_users(params[:licserver_id].to_i, params[:feature_id])
		@users = Licserver.find(params[:licserver_id]).current_users(params[:feature_id])

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

	#  /licservers/:licserver_id/features/lic_info
	#  Get lic_info
	def lic_info
      @features_info = Licserver.find(params[:licserver_id]).get_features_demise

			respond_to do |format|
				format.template
			end
	end

	#  POST   /licservers/:licserver_id/features/:feature_id/toggle_uniq_users(.:format)
	def toggle_uniq_users
		feature = FeatureHeader.where(:licserver_id => params[:licserver_id], :name => params[:feature_id]).first

		if feature.update_attribute(:uniq_users, !feature.uniq_users) then
			flash[:notice] = 'Uniq User policy updated'
		else
			flash[:error] = 'Failed to update Uniq User Policy'
		end

		redirect_to licserver_feature_path(params[:licserver_id], params[:feature_id])
	end

	# get usage report by department
	# GET    /licservers/:licserver_id/features/:feature_id/usage_report(.:format)
	# works well if you past 24 hours, but doesn't scale well
	def usage_report
		@licserver = Licserver.find_by_id(params[:licserver_id])

		respond_to do |format|
			format.html
			format.json {
				results = ActiveRecord::Base.connection.exec_query("select
				ads_departments.company_name, ads_departments.name, count(machines.id) from
				feature_headers
				, features
				, machine_Features
				, machines
				, users
				, ads_users
				, ads_departments
				where
				feature_headers.name = '#{params[:feature_id]}' AND feature_headers.licserver_id = #{params[:licserver_id]}
				and features.feature_header_id = feature_headers.id
				and features.created_at > sysdate - 2 and features.created_at < sysdate
				and machine_features.feature_id = features.id
				and machine_features.machine_id = machines.id
				and machines.user_id = users.id
				and users.ads_user_id = ads_users.id
				and ads_users.ads_department_id = ads_departments.id
				group by
				ads_departments.company_name, ads_departments.name
				union
				select 'no company' as company_name, 'no department' as name, count(machines.id) from
				feature_headers
				, features
				, machine_Features
				, machines
				, users
				where
				feature_headers.name = '#{params[:feature_id]}' AND feature_headers.licserver_id = #{params[:licserver_id]}
				and features.feature_header_id = feature_headers.id
				and features.created_at > sysdate - 2 and features.created_at < sysdate
				and machine_features.feature_id = features.id
				and machine_features.machine_id = machines.id
				and machines.user_id = users.id
				and users.ads_user_id is null
				").rows.map{ |x|
					{ :company_name => x[0], :department_name => x[1],  :machine_count => x[2] }
				}

				<<-EOF
				results = [
					{ :company_name => 'test1', :department_name => 'test_department1', :machine_count => 100 },
					{ :company_name => 'test1', :department_name => 'test_department2', :machine_count => 50 } ,
					{ :company_name => 'test2', :department_name => 'test_department3', :machine_count => 75 },
					{ :company_name => 'test2', :department_name => 'test_department4', :machine_count => 25 }
				]
				EOF

				render :json => results
			}
			format.js
		end
	end

	#  POST   /licservers/:licserver_id/features/:feature_id/mail(.:format)
	# mass email users in the feature
	def mail
		FireworksMailer.address_feature_users(
			Licserver.find(params[:licserver_id]), params[:feature_id], params[:message], current_ads_user.email
		).deliver

		# send mail, and give back status report
		respond_to do |format|
			format.html{
				flash[:notice] = "Successfully send message to users"
				head :ok, content_type => 'text/html'
			}
		end

		js false
	end

	def feature_header_params
		params.require(:feature_header).permit( :name, :licserver_id, :feature_id, :last_seen )
	end

	def feature_params
		params.require(:feature).permit( :current, :max, :name, :licserver_id )
	end

	# GET    /licservers/:licserver_id/features/:feature_id/usage_report_users(.:format)
	def usage_report_users

		@users = AdsUser.includes(:ads_department, :user).joins{ user.machines.features}.where(
			:features => { :licserver_id => params[:licserver_id], :name => params[:feature_id],
				:created_at => 30.days.ago..DateTime.now }
		).uniq.map{ |x| { :user_id => x.user.id, :name => x.name, :department => x.ads_department.name, :company => x.ads_department.company_name}}

		respond_to do |format|
			format.template
		end

	end
end
