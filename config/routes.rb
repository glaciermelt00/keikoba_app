Rails.application.routes.draw do
  root 'users#new'
  resources :users
  get 'signup', to: 'users#new'
  get 'users/guest'
  get 'users/following'
  get 'users/followers'
  get 'sessions/new'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'  
end
