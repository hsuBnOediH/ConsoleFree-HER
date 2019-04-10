Rails.application.routes.draw do
  get '/:id', to:"users#info"
  get '/:id/:repo_name', to:"repos#main"
  root 'application#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
