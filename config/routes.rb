Rails.application.routes.draw do
  root to: 'pages#index'
  get 'signup', to: 'users#new'
  get 'users/guest'
  get 'users/following'
  get 'users/followers'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :users, except: [:new] do
    get :favorites, on: :collection
    get :bookmarks, on: :collection
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :posts do
    resource :favorites, only: [:create, :destroy]
    resource :bookmarks, only: [:create, :destroy]
  end
  resources :pages, only: [:index]
end
