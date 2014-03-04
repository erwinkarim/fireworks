class UsersController < ApplicationController
  
  # GET    /users(.:format)
  def index
  end

  # GET    /users/get_more(.:format)                                        
  # get users from highest id and go backwards 10 users at a time, includes the last id too
  # options => 
  #   start_id  Search from this id instead of User.last.id
  #   next      the the next X users instead of 10
  def get_more
    @user_count = params.has_key? :next ? params[:next].to_i : 10
    if params.has_key? :start_id then
      start_id = params[:start_id]
      @users = User.where{ id.lteq start_id }.order('id desc').limit(10)
    else
      @users = User.where{ id.lteq User.last.id }.order('id desc').limit(10)
    end
    
    respond_to do |format|
      format.html { render :partial => 'accordion', :locals => { :users => @useres } }
      format.json { render :json => @users }
    end
  end
   
  # GET    /users/search(.:format)                                          users#search
  def search
  end
end
