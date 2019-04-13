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
  post '/:username/generate_seed', to: "users#generate_seed"

  post '/users/create',to:"users#create"
  post '/users/validate',to:"users#validate"

  post '/:username/:repo_name/train_and_rank_seed', to: "repos#train_and_rank_seed"
  post '/:username/:repo_name/send_annotating_cache', to: "repos#send_annotating_cache"
  post '/:username/:repo_name/send_sentence', to: "repos#send_sentence"
  post '/:username/:repo_name/update_to_file', to: "repos#update_to_file"
  get '/:username/:repo_name/get_sentence', to: "repos#get_sentence"
  get '/:username/:repo_name/welcome', to: "repos#welcome"
  get '/:username/:repo_name/get_cache_data', to: "repos#get_cache_data"
  get '/:username/:repo_name/get_cache_sentence', to: "repos#get_cache_sentence"
  get '/:username/:repo_name/get_status', to: "repos#get_status"
  get '/:username/:repo_name/get_repo_info', to: "repos#get_repo_info"


  root 'application#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  #
  #
  #
end
