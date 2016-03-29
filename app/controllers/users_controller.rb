class UsersController < ApplicationController

  #  GET    /users/:id(.:format)
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.template
      format.html
    end
  end
end
