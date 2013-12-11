class DashController < ApplicationController
  def index
    @trends = Licserver.get_trendy[0..20]
  end

  # GET    /dash/monthly/:mode(.:format) 
  # get monthly report of things
  def monthly_report
    if params[:mode] == 'licserver' then
      @trends= Licserver.get_trendy({:since => 1.month.ago})
      @top_trends =  @trends[0..40]
    
      if @trends.count > 40 then
        @bottom_trends = @trends[@trends.count-40..@trends.count]
      else
        @bottom_trends = @trends
      end
    end

  end

  def report
    if params.has_key? :days_ago then
      days_ago = params[:days_ago].to_i.days.ago
    end

    if params[:mode] == 'licserver' then
      @trends= Licserver.get_trendy({:since => days_ago })
      @top_trends =  @trends[0..40]
    
      if @trends.count > 40 then
        @bottom_trends = @trends[@trends.count-40..@trends.count]
      else
        @bottom_trends = @trends
      end
    end

  end
end
