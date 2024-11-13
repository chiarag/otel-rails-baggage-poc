Rails.application.routes.draw do
  get 'rolldice', to: 'dice#roll'
end
