Rails.application.routes.draw do
  root to: 'pages#index'
  resources :users
  get 'signup', to: 'users#new'
  get 'users/guest'
  get 'users/following'
  get 'users/followers'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :posts, only: [:new, :create, :destroy]
  resources :pages, only: [:index]
end
