class LicserversController < ApplicationController
	before_filter :authenticate_ads_user!, :only => [ :delete, :new, :create, :edit, :destroy ]

  # GET /licservers/1
  # GET /licservers/1.json
  def show
    @licserver = Licserver.find(params[:id])

		respond_to do |format|
			format.template
			format.html
			format.json {
				render json: {
					:name => @licserver.get_port_at_server,
					:type => @licserver.license_type_id,
					:tags => @licserver.tags.map{ |x| x.title }.join(" ")
				}
			}
		end
  end

  # GET /licservers/new
  # GET /licservers/new.json
  def new
    @licserver = Licserver.new

    respond_to do |format|
      format.html { render :partial => 'form', :locals => { :licserver => nil } }
			format.template { render :partial => 'form.html', :locals => { :licserver => nil } }
      format.json { render json: @licserver }
    end
  end

	# POST   /licservers
	# params licserver-location licserver-tags
	def create
		#sanity checks
		if params[:'licserver-tags'].empty? || params[:'licserver-location'].empty? then
			render :nothing => true, :status => :bad_request
			return
		end

		match_data =  /(?<port_id>\d*)@(?<server_id>[\w.-]+)/.match( params[:'licserver-location'])

		#start creating
		licserver = Licserver.new( :port => match_data[:port_id], :server => match_data[:server_id])

		if licserver.save! then
			#update licserver features
			licserver.update_features

			#add the proper tags
			params[:'licserver-tags'].split.each{ |x| Tag.new(:title => x.downcase, :licserver_id => licserver.id ).save! }
			render :nothing => true, :status => :ok
			return
		else
			render :nothing => true, :status => :bad_request
			return
		end
	end

	# get the license summary
	# /licservers/:licserver_id/summary(.:format)
	def summary
		respond_to do |format|
			format.template { @info = Licserver.find(params[:licserver_id]).license_summary }
		end
	end

	# PATCH  /licservers/:id
	def update
		#sanity checks
		if params[:'licserver-tags'].empty? || params[:'licserver-location'].empty? then
			render :nothing => true, :status => :bad_request
			return
		end

		match_data =  /(?<port_id>\d*)@(?<server_id>[\w.-]+)/.match( params[:'licserver-location'])
		licserver = Licserver.find(params[:id])
		licserver.update_attributes( {:port => match_data[:port_id], :server => match_data[:server_id]})

		if licserver.save! then
			#update tag list
			licserver.update_tag_list params[:'licserver-tags']
			render :nothing => true, :status => :ok
		else
			render :nothing => true, :status => :bad_request
			return
		end

	end

	def licserver_params
		params.require(:licserver).permit( :port, :server, :to_delete, :monitor_idle, :license_type_id )
	end
end
