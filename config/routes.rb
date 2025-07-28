Rails.application.routes.draw do
  post '/searches', to: 'searches#create'

  get  '/analytics',       to: 'analytics#index'
  get  '/analytics/trends', to: 'analytics#trends'
  
  root to: redirect('/index.html')
end
