class TagsController < ApplicationController
  def index
    @tag = Tag.select("title").uniq
  end 

  def create
    @licserver = Licserver.find(params[:licserver_id])
    params[:tag][:title].split(" ").each do |tt|
        @tag = @licserver.tags.create(:title => tt)
    end 
    
    redirect_to :back
  end

  def show
    #@licserver = Licserver.find(
    #  Tag.find(:all, 
    #    :select=>'licserver_id', 
    #    :conditions => 'title = "'+params[:id] +'"').map(&:licserver_id)
    #  )  
    @licserver = Licserver.find(
      Tag.where(:title => params[:id] ).pluck(:licserver_id)
    )

    respond_to do |format|
      format.html
      format.json { render json: @licserver }
    end
  end

  def destroy 
    Tag.delete(params[:id])

    redirect_to :back
  end
end
