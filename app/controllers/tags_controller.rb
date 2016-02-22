class TagsController < ApplicationController
  def index
    @tags = Tag.select(:title).uniq.map{ |x|
      { :title => x.title, :licservers => Tag.where(:title => x.title).map{ |y| y.licserver } }
    }

    respond_to do |format|
      format.template
    end
  end
end
