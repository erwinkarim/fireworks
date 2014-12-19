class AdsUsersController < ApplicationController
  before_filter :set_ads_user, only: [:show, :toggle_watch]

	# GET    /ads_users/:id(.:format)
	# grab id by username (since username is from AD and is unique)
  def show
  end

  # POST   /ads_users/:ads_user_id/toggle_watch
  #   toggles wheater an item needs to be under watch list or not
  #   required
  #     model_type  the name of the model that will be watched/unwatched
  #     model_id    the id of the model that will be watched/ unwatched
  def toggle_watch
    @watch_list = @ads_user.watch_lists.where(:model_id => params[:model_id], :model_type => params[:model_type]).first
    if @watch_list.nil? then
      #not in list, add to list
      @watch_list = @ads_user.watch_lists.new(:model_id => params[:model_id], :model_type => params[:model_type], :active => true)
      @watch_list.save!
    else
      #in the list, check if 
      @watch_list.update_attribute(:active, !@watch_list.active)
    end
  end

	def ads_user_params
		params.rqeuire(:ads_user).permit( :login, :password, :password_confirmation, :remember_me, :email, :username, :domain )
	end

  private 
    def set_ads_user
      @ads_user = AdsUser.where(:login => params[:ads_user_id]).first
    end
end
