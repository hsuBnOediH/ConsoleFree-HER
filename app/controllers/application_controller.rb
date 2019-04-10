class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  #layout "main_layout", :only => [:login]
  def login
  end
end
