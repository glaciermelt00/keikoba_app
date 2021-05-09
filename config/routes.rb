Rails.application.routes.draw do
  root 'users#new'
  # get 'users/show'
  # get 'users/new'
  # get 'users/create'
  # get 'users/edit'
  # get 'users/update'
  # get 'users/destroy'
  resources :users
  get 'signup', to: 'users#new'
  get 'users/guest'
  get 'users/following'
  get 'users/followers'
end
