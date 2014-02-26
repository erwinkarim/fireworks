class ReportSchedulesController < ApplicationController
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
    @schedule = ReportSchedule.find(params[:id])
  end

  # PUT    /report_schedule/:id(.:format)
  # extra parameters : {"utf8"=>"â "authenticity_token"=>"xuLCmTu/pISlBs0LtCK+xP/Fv/NbZiTahoh8VLstkws=", "
  #   "title"=>"test", "time_scope"=>"Last Month", "monitored_licserver"=>["16", "18"], "schedule_terms"=>"true", "id"=>"10020"}
  def update
    @rs = ReportSchedule.find(params[:id])

    @rs.update_attributes(
      :title => params[:title], 
      :time_scope => params[:time_scope],
      :monitored_obj => params[:monitored_licserver].uniq.inject({}){ |hash,e| hash.merge!( e.to_sym => :'_all') }.to_yaml 
    )

    respond_to do |format|
      format.html
      format.json { render :json => @rs }
      format.js  
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
      :monitored_obj => params[:monitored_licserver].uniq.inject({}){ |hash,e| hash.merge!( e.to_sym => :'_all') }.to_yaml 
    )
    @rs.save!

    respond_to do |format|
      format.html
      format.json { render :json => @rs }
      format.js  
    end
  end

  # DELETE /report_schedules/:id
  def destroy
  end

  # GET    /report_schedules/:report_schedule_id/accordion
  # generate an accordion group to plug it in an accordion
  def accordion
    @rs = ReportSchedule.find(params[:report_schedule_id])
    
    respond_to do |format|
      format.html { render :partial => 'schedule-accordion-group', :locals => { :schedule => @rs } }
    end
  end
end
