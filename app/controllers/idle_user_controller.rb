class IdleUserController < ApplicationController
  def report
    #report idle use time and update the table on idle use listing
    
    if (params.has_key?(:user) && params.has_key?(:host) && params.has_key?(:idle)) then
     
      puts "Getting idle client updates from "+params[:user]+"@"+params[:host] 
      @idleuser = IdleUser.where("user = ? and hostname = ?", params[:user], params[:host]).first 
      if @idleuser.nil? then
        @idleEntry = IdleUser.new(:user => params[:user], :hostname => params[:host], 
          :idle => params[:idle])
        if @idleEntry.save then
          render :text => 'new entry created'
          puts "Created new entry for "+params[:user] +"@"+param[:host]
        else
          render :text => 'failed to create entry'
          puts "Failed to Create entry for "+ params[:user] + "@"+params[:host]
        end
      else
        if @idleuser.update_attribute(:idle, params[:idle]) then
          render :text => 'update user '+ params[:user] +"@" + params[:host] + " with idle time:" +  params[:idle]
          puts "Successfully updates "+params[:user]+"@"+params[:host]
        else
          render :text => 'Fail to update user'
          puts "Update "+params[:user]+"@"+params[:host]+" failed"
        end
      end
    else
      render :text => 'not enough keys'
    end
  end

  def show
      @idleuser = IdleUser.all
  end
end
