ActiveSupport.on_load :action_controller_base do
  include Pagy::Backend
end
