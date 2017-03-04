Rails.application.routes.draw do
	root to: 'terms#index'

  post '/register', to: 'users#create',    as: 'register'
  post '/login',    to: 'sessions#create', as: 'login'

  resources :terms, only: [:show]
end
