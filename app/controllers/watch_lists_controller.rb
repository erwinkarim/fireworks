class WatchListsController < ApplicationController
  before_filter :set_watch_list, only: [:show, :edit, :update, :destroy]
	respond_to :js, :html, :json

  def index
    @watch_lists = WatchList.all
    respond_with(@watch_lists)
  end

  def show
    respond_with(@watch_list)
  end

  def new
    @watch_list = WatchList.new
    respond_with(@watch_list)
  end

  def edit
  end

  def create
    @watch_list = WatchList.new(params[:watch_list])
    @watch_list.save
    respond_with(@watch_list)
  end

  def update
    @watch_list.update_attributes(params[:watch_list])
    respond_with(@watch_list)
  end

  def destroy
    @watch_list.destroy
    respond_with(@watch_list)
  end

  private
    def set_watch_list
      @watch_list = WatchList.find(params[:id])
    end
end
