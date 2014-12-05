class WatchListsController < ApplicationController
  before_filter :authenticate_ads_user!
  before_filter :set_watch_list, only: [:show, :edit, :update, :destroy]
	respond_to :js, :html, :json

	# GET    /ads_users/:ads_user_id/watch_lists(.:format)
  def index
    respond_to do |format|
      format.html
      format.template {
        #@watch_lists = AdsUser.where(:login => params[:ads_user_id]).first.watch_lists.where(:active => true)
        @watch_lists = AdsUser.where(:login => params[:ads_user_id]).first.watch_lists.where(:active => true).map{ 
					|x| { :entry => x, :handle_text => show_text(x.model_type.constantize.find(x.model_id)), 
						:handle_url => url_text(x.model_type.constantize.find(x.model_id) )  
					} 
				}
      }
    end
  end


	# GET    /ads_users/:ads_user_id/watch_lists/:id(.:format) 
  def show
    respond_to do |format|
      format.js
      format.template {
        if @watch_list.model_type == 'FeatureHeader' then
          feature_header = FeatureHeader.find(@watch_list.model_id)
          @licserver = Licserver.find(feature_header.licserver_id)
          params[:id] = feature_header.name
          render 'features/show'
				elsif @watch_list.model_type == 'Licserver' then
					# render nothing. licserver loading is handle at javascript level
					render nothing: true
				elsif @watch_list.model_type == 'Tag' then
          @tag_handle = Tag.find(@watch_list.model_id)
          @tag = @tag_handle.title
          if ads_user_signed_in? then
            #tags could be tricky. need to revisit this later
            @watched = current_ads_user.watch_lists.where(:model_type => 'Tag', :model_id => @tag_handle.id ).first
          end
          @licservers = Licserver.find(
            Tag.where(:title => @tag_handle.title ).pluck(:licserver_id)
          )
          render 'tags/show'
				elsif @watch_list.model_type == 'User' then
					@user = User.find(@watch_list.model_id)
					render 'users/show'
				elsif @watch_list.model_type == 'ReportSchedule' then
					@schedule = ReportSchedule.find(@watch_list.model_id)
					render 'report_schedules/show'
        end
      }
    end
  end

	# GET    /ads_users/:ads_user_id/watch_lists/new(.:format)
  def new
    @watch_list = WatchList.new
    respond_with(@watch_list)
  end

	# GET    /ads_users/:ads_user_id/watch_lists/:id/edit(.:format)
  def edit
  end

	# create new watch list
	# POST   /ads_users/:ads_user_id/watch_lists(.:format)   
  def create
    #@watch_list = WatchList.new(params[:watch_list])
    #@watch_list.save
    #respond_with(@watch_list)
  end

	#  PUT    /ads_users/:ads_user_id/watch_lists/:id(.:format)
  def update
    @watch_list.update_attributes(params[:watch_list])
    respond_with(@watch_list)
  end

	#  DELETE /ads_users/:ads_user_id/watch_lists/:id(.:format) 
  def destroy
    @watch_list.destroy
    respond_with(@watch_list)
  end

  private
    def set_watch_list
			@watch_list = AdsUser.where(:login => params[:ads_user_id]).first.watch_lists.find(params[:id])
      #@watch_list = WatchList.find(params[:id])
    end

		# returns the identifying text for the model_type.find(model_id)
		def show_text handle
			case handle
			when Licserver
				return handle.port.to_s + '@' + handle.server
			when User
				return handle.name
			when FeatureHeader
				return handle.name
			when Tag
				return handle.title
			when ReportSchedule
				return handle.title
			else
				return 'Unknown Class'
			end
		end

		#return the path to access this model
		def url_text handle
			case handle
			when Licserver
				return licserver_path(handle.id)
			when User
				return user_path(handle.id)
			when FeatureHeader
				return licserver_feature_path(handle.licserver_id, handle.name)
			when Tag
				return tag_path(handle.title)
			when ReportSchedule
				return report_schedule_path(handle.id)
			else
				return '#'
			end
		end
end
