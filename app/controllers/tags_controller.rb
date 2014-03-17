class TagsController < ApplicationController
  def index
  end 

  def create
    @licserver = Licserver.find(params[:licserver_id])
    params[:tag][:title].split(" ").each do |tt|
        @tag = @licserver.tags.create(:title => tt)
    end 
    
    redirect_to :back
  end

  #  GET    /tags/:id
  #  params[:id] is differnt because it'd shows tags that is match with
  def show
    #@licserver = Licserver.find(
    #  Tag.find(:all, 
    #    :select=>'licserver_id', 
    #    :conditions => 'title = "'+params[:id] +'"').map(&:licserver_id)
    #  )  
    @licservers = Licserver.find(
      Tag.where(:title => params[:id] ).pluck(:licserver_id)
    )

    respond_to do |format|
      format.html { 
        if @licservers.empty? then
          render status: :not_found
        else 
          render :partial => 'display_licservers' , :locals => { :licservers => @licservers, :tag => params[:id] } 
        end
      } 
      format.json { render json: @licserver }
    end
  end

  def destroy 
    Tag.delete(params[:id])

    redirect_to :back
  end

  # GET    /tags/gen_accordion(.:format)
  # render the accordion
  def gen_accordion
    @tags = Tag.select("title").uniq
    
    respond_to do |format|
      format.html{ render :partial => 'display', :locals => { :tags => @tags } }
      format.json{ render :json => @tags }
    end
  end

end
