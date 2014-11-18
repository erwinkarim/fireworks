class UsersController < ApplicationController
  
  # GET    /users(.:format)
  def index
  end

  # GET    /users/get_more(.:format)                                        
  # get users from highest id and go backwards 10 users at a time, 
  #   includes the last id if start_id is not specified
  # options => 
  #   start_id    Search from this id instead of User.last.id
  #   next        the the next X users instead of 10
  def get_more
    @user_count = params.has_key? :next ? params[:next].to_i : 10
    if params.has_key? :start_id then
      start_id = params[:start_id]
      @users = User.where{ id.lt start_id }.order('id desc').limit(10)
    else
      @users = User.where{ id.lteq User.last.id }.order('id desc').limit(10)
    end
    
    respond_to do |format|
      format.html { render :partial => 'accordion', :locals => { :users => @users } }
      format.json { render :json => @users }
    end
  end
   
  # GET    /users/search(.:format)                                          users#search
  #   returns user ids when you search
  # options =>
  #   query     search terms query, mandatory, otherwise return nil
  #   start_id  start searching from this id, otherwise start from User.last.id
  def search
    #query = params.has_key? :query ? ('%' + params[:query] + '%') : ""
    query = (params.has_key? :query) ? query = '%' + params[:query] + '%' : ''
    start_id = (params.has_key? :start_id) ? (params[:start_id].to_i - 1 ) : User.last.id
    @users = User.where{ (name.matches query) & (id.lteq start_id) }.order('id desc').limit(20)   

    respond_to do |format|
      format.html { render :partial => 'accordion', :locals => { :users => @users } }
      format.json { 
				#to give back in typeahead format
        init_hash = { :options => [] }
        @users.each{ |x| init_hash[:options] << x.name }
        render :json => init_hash 
      }
    end
  end

  # GET    /users/:id(.:format)
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @user }
    end
  end
end
