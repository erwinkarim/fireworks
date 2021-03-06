class ReportSchedulesController < ApplicationController
	before_filter :authenticate_ads_user!

  def index
    @schedules = ReportSchedule.all

    respond_to do |format|
      format.html
      format.json { render json: @schedules }
    end
  end

  #GET    /report_schedule/:id(.:format)
  # get report schedule
  def show
		respond_to do |format|
			@schedule = ReportSchedule.find(params[:id])
			format.html
			format.template{
				@delete_enabled = params.has_key?(:delete_enabled) && params[:delete_enabled] == 'true' ?  true : false
			}
		end
  end

  # PUT    /report_schedule/:id(.:format)
  # extra parameters : {"utf8"=>"â "authenticity_token"=>"xPqgE9sM9Fa5ZNkDQKMY9gL1qLxcffcvDHMdy/sdBSE=", "
  #   title"=>"petrel", "time_scope"=>"Last Week", "monitored_type"=>["petrel", "petrel"], "monitored_licserver"=>["1", "5"], 
  #   "schedule_terms"=>"true", "id"=>"10080"}
  def update
    @rs = ReportSchedule.find(params[:id])

    @rs.update_attributes(
      :title => params[:title], 
      :time_scope => params[:time_scope],
      #:monitored_obj => params[:monitored_licserver].uniq.inject({}){ |hash,e| hash.merge!( e.to_sym => :'_all') }.to_yaml,
      :monitored_obj => (0..params[:monitored_licserver].count-1).each.inject({}){ 
        |m,b| m =m.merge( { params[:monitored_licserver][b] => params[:monitored_type][b] } ) 
      }.to_yaml,
      :scheduled => params[:schedule_terms] == 'true'
    )

    respond_to do |format|
      format.json { render :json => @rs }
      format.js  
			format.template
    end
  end

  # POST   /report_schedule(.:format)
  # extra parameters : {"utf8"=>"â "authenticity_token"=>"xuLCmTu/pISlBs0LtCK+xP/Fv/NbZiTahoh8VLstkws=", "
  #   title"=>"test", "time_scope"=>"Yesterday", "monitored_licserver"=>["10081", "10"], "schedule_terms"=>"true"}
  #
  def create
    @rs = ReportSchedule.new(
      :title => params[:title],
      :time_scope => params[:time_scope],
      #:monitored_obj => params[:monitored_licserver].uniq.inject({}){ |hash,e| hash.merge!( e.to_sym => :'_all') }.to_yaml,
      :monitored_obj => (0..params[:monitored_licserver].count-1).each.inject({}){ 
        |m,b| m =m.merge( { params[:monitored_licserver][b] => params[:monitored_type][b] } ) 
      }.to_yaml,
      :scheduled => params[:schedule_terms] == 'true'
    )
    @rs.save!
		@delete_enabled = true

    respond_to do |format|
      format.html
      format.json { render :json => @rs }
			format.template
      format.js  
    end
  end

  # DELETE /report_schedules/:id
  def destroy
    @rs = ReportSchedule.find(params[:id])
    @rs.destroy
  
    respond_to do |format|
      format.js
    end
  end

  # GET    /report_schedules/:report_schedule_id/accordion
  # generate an accordion group to plug it in an accordion
  def accordion
    @rs = ReportSchedule.find(params[:report_schedule_id])
    
    respond_to do |format|
      format.html { render :partial => 'schedule-accordion-group', :locals => { :schedule => @rs } }
    end
  end

  #  GET /report_schedules/:report_schedule_id/gen_monitored_obj_listings(.:format)
  def gen_monitored_obj_listings

    if params[:report_schedule_id] = 0 then
      @schedule = ReportSchedule.new
    else 
      @schedule = ReportSchedule.find(params[:report_schedule_id]) 
    end

    respond_to do |format|
      format.html{ render :partial => 'monitored_obj_listings', :locals => { :schedule => @schedule}  }
    end
  end

	def report_schedule_params
		params.require(:report_schedule).permit( :monitored_obj, :schedule, :title, :time_scope, :scheduled )
	end

	def report_params
		params.require(:report).permit( :body, :title, :start_date, :end_date, :status )
	end
end
