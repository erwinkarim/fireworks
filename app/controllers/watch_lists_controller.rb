class WatchListsController < ApplicationController
  before_filter :authenticate_ads_user!
  before_filter :set_watch_list, only: [:show, :edit, :update, :destroy]
	respond_to :js, :html, :json

	# GET    /ads_users/:ads_user_id/watch_lists(.:format)
  def index
    respond_to do |format|
      format.html
      format.template {
        @watch_lists = AdsUser.where(:login => params[:ads_user_id]).first.watch_lists
      }
    end
  end

	# GET    /ads_users/:ads_user_id/watch_lists/:id(.:format) 
  def show
    respond_to do |format|
      format.js
      format.template {
        #if @watch_list.model_type == 'FeatureHeader' then
        #  feature_header = FeatureHeader.find(@watch_list.model_id)
        #  @licserver = Licserver.find(feature_header.licserver_id)
        #  params[:id] = feature_header.name
        #  render 'features/show'
        #end
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
end