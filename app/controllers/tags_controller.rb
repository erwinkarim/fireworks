class TagsController < ApplicationController
  def index
		if params.has_key? :licserver_id then
			@tags = Licserver.find(params[:licserver_id]).tags
		end
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
    @tag = params[:id]
		@tag_handle = Tag.where(:title => params[:id]).first
    @licservers = Licserver.find(
      Tag.where(:title => params[:id] ).pluck(:licserver_id)
    )

    respond_to do |format|
      #format.html { 
      #  if @licservers.empty? then
      #    render status: :not_found
      #  else 
      #    if params[:mode] == 'list' then
      #      render :partial => 'list_licservers' , :locals => { :licservers => @licservers, :tag => params[:id] } 
      #    else
      #      render :partial => 'display_licservers' , :locals => { :licservers => @licservers, :tag => params[:id] } 
      #    end
      #  end
      #} 
      format.html
      format.json { render json: @licservers }
			format.template
    end
  end

  def destroy 
    Tag.delete(params[:id])

    redirect_to :back
  end

  # GET    /tags/gen_accordion(.:format)
  # render the accordion
  def gen_accordion
    @tags = Tag.select("title, min(id) as id").group(:title)
    
    respond_to do |format|
      #format.html{ render :template => 'tags/gen_accordion.template', :locals => { :@tags => @tags } }
      format.json{ render :json => @tags }
			format.template
    end
  end


  # GET    /tags/search(.:format)
  # options =>
  #   query   search term query
  def search
    query = (params.has_key? :query) ? query = '%' + params[:query] + '%' : ''
    @tags = Tag.select('title').uniq.where{ (title.matches query) }.limit(20)
    respond_to do |format|
      format.template{ render :template => 'tags/gen_accordion.template', :locals => { :@tags => @tags } }
      format.json {
        init_hash = { :options => [] }
        @tags.each{ |x| init_hash[:options] << x.title }
        render :json => init_hash 
      }
    end
  end

  # GET    /tags/:tag_id/gen_licservers(.:format)
  def gen_licservers
    @licservers = Licserver.where(
      :id => Tag.where(:title => params[:tag_id]).pluck(:licserver_id) 
    )

    respond_to do |format|
      format.html{ render :partial => 'licservers_options_tags', :locals => { :licservers => @licservers } }
      format.json{ render :json => @licservers } 
    end
  end

	def tag_params
		params.rquire(:tag).permit(:title)
	end
end
