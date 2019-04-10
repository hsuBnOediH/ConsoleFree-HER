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



  def repo_status_initializer
    return "ssss"
    $line_num = 1
    $prev_line_num = 1
    $seed_status = true
    $seed_line_annotated = 0
    $seed_line_total = 0
    $corpus_line_annotated = 0
    $corpus_line_total = 0
    $time = 1


  end

  def repo_directory_setup files, gazs

    File.open("db/temp.txt", 'wb') { |file| file.write(data) }
    system("sed", "-i", "1,4d;$d", "db/temp.txt")
    setup_repo
    system("mv", "db/temp.txt", $path+"Data/Original/")
  end





  def add_repo

    repo_info = request.body.read
    repo_info = JSON.parse(repo_info)

    repo_name = repo_info["repo_name"]
    language = repo_info["language"]
    seed_size = repo_info["seed_size"]
    sort_method = repo_info["sort_method"]
    user_id = repo_info["user_id"]

    entities = ""
    repo_info["entities"].each do |entity|
      entities += entity + " "
    end

    #files = repo_info["files"]
    #gazs = repo_info["gazs"]

    Repo.new(:repo_name => repo_name,
             :language => language,
             :seed_size => seed_size.to_i,
             :sort_method => sort_method,
             :entities => entities,
             :status => repo_status_initializer).save

    User.find_by_id(user_id).repos << Repo.last

    # respond_to do |format|
    #
    #   msg = {:status => true, :url => @user.id.}
    #
    #   format.json {render :json => msg}
    #
    # end
    #repo_directory_setup(files, gazs)


    # File.open("db/temp.txt", 'wb') { |file| file.write(data) }
    # system("sed", "-i", "1,4d;$d", "db/temp.txt")
    # setup_repo
    # system("mv", "db/temp.txt", $path+"Data/Original/")
    #
    # generate_seed

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

