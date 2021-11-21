class ApplicationController < ActionController::Base
  layout -> { nil if turbo_frame_request? }
end
