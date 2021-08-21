class ApplicationController < ActionController::Base
  before_action { response.headers["Turbo-Frame"] = flash["Turbo-Frame"].tap { flash.delete("Turbo-Frame") } }

  def redirect_to(*arguments, turbo_frame: nil, **options, &block)
    flash["Turbo-Frame"] = response.headers["Turbo-Frame"] = turbo_frame

    super(*arguments, **options, &block)
  end
end
