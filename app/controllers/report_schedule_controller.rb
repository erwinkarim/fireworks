class ReportScheduleController < ApplicationController
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
  end
end
