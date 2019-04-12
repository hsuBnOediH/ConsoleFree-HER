Rails.application.routes.draw do
  get '/:username', to:"users#info"


  get '/:username/:repo_name', to:"repos#main"

  post '/:username/get_repo_user', to: "users#get_repo_user"
  post '/:username/delete_repo', to: "users#delete_repo"
  post '/:username/share_repo', to: "users#share_repo"
  post '/:username/delete_repo', to: "users#delete_repo"
  post '/:username/add_repo', to: "users#add_repo"
  post '/:username/cp_file', to: "users#cp_file"
  post '/:username/cp_gaz', to: "users#cp_gaz"
  post '/users/create',to:"users#create"
  post '/users/validate',to:"users#validate"
  root 'application#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  #
  #
  #
end
