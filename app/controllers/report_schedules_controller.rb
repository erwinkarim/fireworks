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
  def update
    flash[:notice] = 'updated'
  end

  # POST   /report_schedule(.:format)
  def create
    @rs = ReportSchedule.last

    respond_to do |format|
      format.html
      format.json { render :json => @rs }
      format.js  
    end
  end

  # DELETE /report_schedules/:id
  def destroy
  end
end
