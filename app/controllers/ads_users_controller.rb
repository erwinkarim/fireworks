class AdsUsersController < ApplicationController

	# GET    /ads_users/:id(.:format)
	# grab id by username (since username is from AD and is unique)
  def show
		@ads_user = AdsUser.where(:login => params[:id]).first
  end
end
