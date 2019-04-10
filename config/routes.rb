Rails.application.routes.draw do
  get '/:id', to:"users#info"

  get '/:id/get_repo_info', to:"users#get_repo_info"

  get '/:id/:repo_name', to:"repos#main"

  post '/users/add_repo'
  post '/users/create',to:"users#create"
  post '/users/validate',to:"users#validate"
  root 'application#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
