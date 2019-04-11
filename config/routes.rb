Rails.application.routes.draw do
  get '/:id', to:"users#info"


  get '/:id/:repo_name', to:"repos#main"

  post '/:id/add_repo', to: "users#add_repo"
  post '/:id/cp_file', to: "users#cp_file"
  post '/:id/cp_gaz', to: "users#cp_gaz"
  post '/users/create',to:"users#create"
  post '/users/validate',to:"users#validate"
  root 'application#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
