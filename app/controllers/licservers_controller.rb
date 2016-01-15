class LicserversController < ApplicationController
	before_filter :authenticate_ads_user!, :only => [ :delete, :new, :create, :edit, :destroy ]

  # GET /licservers/1
  # GET /licservers/1.json
  def show
    @licserver = Licserver.find(params[:id])

		respond_to do |format|
			format.template
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

	def licserver_params
		params.require(:licserver).permit( :port, :server, :to_delete, :monitor_idle, :license_type_id )
	end
end
