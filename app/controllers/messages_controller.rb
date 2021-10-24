class MessagesController < ApplicationController
  def index
    @messages = Message.most_recent_first
  end
end
