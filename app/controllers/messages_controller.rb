class MessagesController < ApplicationController
  def index
    @page, @messages = pagy Message.most_recent_first
  end
end
