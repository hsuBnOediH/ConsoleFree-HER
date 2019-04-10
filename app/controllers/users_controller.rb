require 'json'
class UsersController < ApplicationController
  before_action :set_user, only: [:info]

  layout "main_layout"
  def info
    @user_repo_array =[]

    ReposUser.where("user_id='"+@user.id.to_s+"'").find_each do |repo|

      Repo.where("id='"+repo.repo_id.to_s+"'").find_each do |re|
        url = @user.id.to_s + "/" + re.repo_name
        @user_repo_array << url
      end

    end


  end



  def get_repo_info

    input =  User.find_by_id(params[:id])
    #*************************************
    #get details of repo information
    #*************************************

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => input}

      format.json {render :json => msg}

    end

  end


  def create

    account_info = request.body.read
    account_info = JSON.parse(account_info)
    username = account_info["username"]
    password = account_info["password"]

    status = true

    if User.where(:username => username).blank?
        User.new(:username => username, :password=>password).save
     else
        status = false
    end
    respond_to do |format|

      msg = {:status => status, :user_id => User.find_by_username(username).id}

      format.json {render :json => msg}

    end

  end

  def validate

    account_info = request.body.read
    account_info = JSON.parse(account_info)
    username = account_info["username"]
    password = account_info["password"]

    if User.where(["username = ? and password = ?", username, password]).blank?

      respond_to do |format|

        msg = {:status => false}

        format.json {render :json => msg}

      end

    else

      respond_to do |format|

        msg = {:status => true, :user_id => User.find_by_username(username).id}

        format.json {render :json => msg}

      end


    end


  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :password)
    end

end

