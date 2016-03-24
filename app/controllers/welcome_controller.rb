class WelcomeController < ApplicationController
  def index
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

  #must have query
  def search
    if params.has_key? :query then
      @tags = Tag.search(params[:query])
    else
      @tags = Tag.select(:title).uniq.map{ |x|
        { :title => x.title, :licservers => Tag.where(:title => x.title).map{ |y| y.licserver } }
      }
    end

    respond_to do |format|
      format.template {
        render :file => "tags/index.template", :locals => { :'@tags' => @tags }
      }
    end
  end

end
