class WelcomeController < ApplicationController
  def index
    @userAgent=request.env['HTTP_USER_AGENT']
    if @userAgent.downcase.match('linux') then
        @clientOS = 'Linux'
    elsif @userAgent.downcase.match('windows') then
        @clientOS = 'Windows'
    elsif @userAgent.downcase.match('os x') then
        @clientOS = 'Mac Os X'
    else
        @clientOS = nil
    end
  end

  def download_client
    if params.has_key? :type then
      if params[:type] == 'Windows' then
        send_file "#{Rails.root}/lib/client/fireworks_client_windows.zip"
      elsif params[:type] == 'Mac Os X' then
        send_file "#{Rails.root}/lib/client/fireworks_client_mac.zip"
      end
    end
  end

  def about
  end

  def tech
  end

  def notice
    render :partial => 'notice', :locals => { :msg => params[:msg] }
  end

	def disclaimer
	end

  def search
  end
end
