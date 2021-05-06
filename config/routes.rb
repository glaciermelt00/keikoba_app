Rails.application.routes.draw do
  root 'users#show'
  # get 'users/show'
  # get 'users/new'
  # get 'users/create'
  # get 'users/edit'
  # get 'users/update'
  # get 'users/destroy'
  resources :users
  get 'users/guest'
  get 'users/following'
  get 'users/followers'
end
