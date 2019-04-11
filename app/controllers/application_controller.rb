class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout "application_no_header_footer", :only => [:login]
  def login
  end
end
