class AuthorsController < ApplicationController
  def show
    @author = params[:id]
    @messages = Message.where author: @author
  end
end
