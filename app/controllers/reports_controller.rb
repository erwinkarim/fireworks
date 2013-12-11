class ReportsController < ApplicationController
  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reports }
    end
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    @report = Report.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
      format.csv { send_data @report.to_csv, :filename => @report.title + '.csv' }
      format.xls { send_data @report.to_xls, :filename => @report.title + '.xls' }
    end
  end

  # GET /reports/new
  # GET /reports/new.json
  def new
    @report = Report.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report }
    end
  end

  # GET /reports/1/edit
  def edit
    @report = Report.find(params[:id])
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(params[:report])

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render json: @report, status: :created, location: @report }
      else
        format.html { render action: "new" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reports/1
  # PUT /reports/1.json
  def update
    @report = Report.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(params[:report])
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end

  #to configure reports scheduling
  def schedule_configure
    @report_schedules = ReportSchedule.all

    respond_to do |format|
      format.html 
      format.json { render json: @report_schedules }
    end
  end

  #create new schedule
  def schedule_create
    @report_schedule = ReportSchedule.new(
      :title => params[:schedule_name], 
      :monitored_obj => { params[:licserver_to_monitor_select].to_sym => :_all }, 
      :schedule =>  params[:report_Hz] == 'Once Off' ? 
        { :ad_hoc => true } : { :ad_hoc => false, params[:report_Hz] => [ "0800" ] },
      :time_scope => params[:time_scope_select]
    )

    respond_to do |format|
      if @report_schedule.save then
         format.html  { redirect_to reports_path, notice: 'Reports Schedule Created' } 
      else
          format.html { redirect_to reports_schedule_new_path, error: 'Error Creating Report' }
      end
    end

  end

  #get a list of schedule
  def schedule
    @schedules = ReportSchedule.all

    respond_to do |format|
      format.html
      format.json { render json: @schedules }
    end
  end

  # GET    /reports/schedule/:schedule_id(.:format)
  # show reports schdueles detail
  def reports_schedule
  
    @schedule = ReportSchedule.find(params[:schedule_id])
  
    respond_to do |format|
      format.html
      format.json { render json: @schedule }
    end
  end

  # GET    /reports/schedule/:schedule_id/reports(.:format)
  # get a list of reports that's connected with :schedule_id
  #
  def reports_schedule_detail
    @reports = ReportSchedule.find(params[:schedule_id]).reports.order(:id).reverse[0..50]

    respond_to do |format|
      format.json { render json: @reports} 
    end
  end
end
