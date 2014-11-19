class LicserversController < ApplicationController
	before_filter :authenticate_ads_user!, :only => [ :delete, :new, :create, :edit, :destroy ]

  # GET /licservers
  # GET /licservers.json
  def index
    #@licservers = Licserver.where(:to_delete => false)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /licservers/1
  # GET /licservers/1.json
  def show
    @licserver = Licserver.find(params[:id])
    licserver = @licserver
    #@tags = @licserver.tags
    #@features = @licserver.feature_headers.where{ last_seen.gt 1.day.ago }.map{ |item| {:name => item.name } }
    #if @features.empty? then
    #  @features = nil
    #end
    if ads_user_signed_in? then
      @watched = current_ads_user.watch_lists.where(:model_type => 'Licserver', :model_id => @licserver.id ).first
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @licserver }
			format.template { render :template => 'licservers/show.template', :locals => { :licserver => @licserver } }
    end
  end

  # /licservers/:licserver_id/show_template
  # display the template for tags/index page
  def show_template
      @licserver = Licserver.find(params[:licserver_id])

      respond_to do |format|
        format.html { render :partial => 'show_template', :locals => { :licserver => @licserver } }
        format.json { render :json => @licserver }
      end
  end

  # GET /licservers/new
  # GET /licservers/new.json
  def new
    @licserver = Licserver.new

    respond_to do |format|
      format.html { render :partial => 'form', :locals => { :licserver => nil } }
      format.json { render json: @licserver }
    end
  end

  # GET /licservers/1/edit
  def edit
    @licserver = Licserver.find(params[:id])
		
		respond_to do |format|
			format.html { render :partial => 'form', :locals => { :licserver => @licserver } }
		end
  end

  # POST /licservers
  # POST /licservers.json
  def create
    omnibar = params[:lic]
    if omnibar.include? '@' then
      @licserver = Licserver.new(:port => omnibar.split('@').first, :server => omnibar.split('@').last)  
    else
      @licserver = Licserver.new(:server => omnibar)
    end

    respond_to do |format|
      if @licserver.save
        Feature.update_features(@licserver.id)
				@features = @licserver.feature_headers.where{ last_seen.gt 1.day.ago }.map{ |item| {:name => item.name } }
				@licserver.update_tag_list( params[:tags] )
        #format.html { redirect_to @licserver, notice: 'Licserver was successfully created.' }
        format.html { render :partial => 'accordion', :locals => { :licservers => [@licserver] } }
        format.json { render json: @licserver, status: :created, location: @licserver }
      else
        format.html { render status: :unporcessable_entity }
        format.json { render json: @licserver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /licservers/1
  # PUT /licservers/1.json
  def update
    @licserver = Licserver.find(params[:id])
	
		#update taggings
		
    respond_to do |format|
      if @licserver.update_attributes(params[:licserver])
				@licserver.update_tag_list(params[:tags])
        format.html { render :partial => 'form', :locals => { :licserver => @licserver } }
        format.json { head :no_content }
				format.js
      end
    end
  end

  # DELETE /licservers/1
  # DELETE /licservers/1.json
  def destroy
    @licserver = Licserver.find(params[:id])
    
    #put delete in background to improve interface reponsiveness
    #@licserver.destroy
    @licserver.update_attributes(:to_delete => true)
    @licserver.save 

    @licserver.delay.destroy

    respond_to do |format|
      format.html { redirect_to licservers_url }
      format.json { head :no_content }
			format.js
    end
  end

	# POST   /licservers/:licserver_id/update_settings(.:format) 
  def update_settings
    @lic = Licserver.find(params[:licserver_id])

    #check the form and update the settings
    if params.has_key? :monitorIdle then
      @lic.update_attribute(:monitor_idle, true)
    else
      @lic.update_attribute(:monitor_idle, false)
    end

    redirect_to :back
  end

  def trending
    #get trendy licservers
  end

  # GET    /licserver/:licserver_id/analysis(.:format) 
  # get analysis
  def analysis
    @licserver = Licserver.find(params[:licserver_id])

    #input error margin is 0.1%  
    feature_error_margin = @licserver.features.count * 0.001
    #feature_error_margin = 0

    @anal_dump = @licserver.features.where{ 
          # 0800 to 1700 malaysia time because data is stored in UTC
          ( to_char( created_at, 'HH24:MI:SS') > '01:00:00' ) & 
          ( to_char( created_at, 'HH24:MI:SS' ) < '10:00:00' ) & 
          ( to_char( created_at, 'D') != 1 ) & ( to_char( created_at, 'D' ) != 7 ) & 
          ( created_at.gt 6.months.ago ) 
          #( to_char( created_at, 'MM') >= 5 ) & ( to_char( created_at, 'MM') <= 7)  }.
      }.select{ [name, sum(current).as(total_current), sum(max).as(total_max), count(max).as(max_count) ] }.
      group{ name }.
      having{ count(name) > feature_error_margin }.
      map{ |x| [ x.name, x.total_current, x.total_max, x.max_count ]  }
  end

	# GET    /licservers/get_more
	# options 
	#		last_id		start from last_id and above
	def get_more
		if params.has_key? :last_id then
			last_id = params[:last_id]
		else
			last_id = 0
		end

		@licservers = Licserver.where{ (id.gt last_id) & (to_delete.eq false) }.order(:id)

		respond_to do |format|
			format.html { render :partial => 'accordion', :locals => { :licservers => @licservers }  } 
			format.json { render :json => @licservers }
		end
	end

	# GET /licservers/:licserver_id/info
	# return info template when queried
	def info
		@licserver = Licserver.find(params[:licserver_id])
    @features = @licserver.feature_headers.where{ last_seen.gt 1.day.ago }.map{ |item| {:name => item.name } }

		respond_to do |format|
			format.html { render :partial => 'info', :locals => { :licserver => @licserver , :features => @features}  } 
			format.json { render :json => @licserver }
		end
	end

	# GET    /licservers/search
	#	search for licservers based on query
	#	optiosn
	#		query		the search query
	def search
		#query = (params.has_key? :query) ? query = '%' + params[:query] + '%' : ''
		query = (params.has_key? :query) ? params[:query] : ''
		# need to handle case of port@server search term
		@licservers = (Licserver.where{ server.matches query }.limit(20) + 
			Licserver.where{ port.matches query }.limit(20) ).uniq

    respond_to do |format|
      format.html { render :partial => 'accordion', :locals => { :licservers => @licservers } }
      format.json { 
        #to give back in typeahead format
        init_hash = { :options => [] }
        @licservers.each{ |x| init_hash[:options] << (x.port.to_s + '@' + x.server) }
        render :json => init_hash 
      }
		end
	end
end
