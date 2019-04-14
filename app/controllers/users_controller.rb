require 'json'
class UsersController < ApplicationController
  before_action :set_user, only: [:info, :add_repo, :cp_file, :cp_gaz, :share_repo, :get_repo_user, :delete_repo, :generate_seed]
  #before_action :set_repo_path, only: [:cp_file, :cp_gaz, :add_repo]

  layout "main_layout", :only => [:login]


  def info
    @user_repo_array = []
    @user_repo_info = []
    @card_color_array = []
    @card_color_set = %w(#2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3 #2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3
#2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3 #2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3
#2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3
#2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3
#2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3
#2ECC40 #01FF70 #FFDC00 #FF851B #FF4136 #DDDDDD #8379fb #31f5b5 #ffcb33 #ff6a33 #31f3f3)

    ReposUser.where("user_id='" + @user.id.to_s + "'").find_each do |repo|

      Repo.where("id='" + repo.repo_id.to_s + "'").find_each do |re|
        color = @card_color_set.pop
        url = @user.username + "/" + re.repo_name
        @user_repo_array << url
        @user_repo_info << [re.repo_name, re.entities, re.language, @user.username + "_" + re.repo_name, color]
      end

    end

  end

  def find_repo(name)

    ReposUser.where("user_id='" + @user.id.to_s + "'").find_each do |repo|
      Repo.where("id='" + repo.repo_id.to_s + "'").find_each do |re|
        if re.repo_name == name
          return re
        end
      end
    end
  end

  def repo_status_initializer

    return "1 1 true 0 0 0 0 1"

  end

  def cp_gaz

    data = request.body.read

    name = @user.repos[-1].id.to_s + "_" + @user.repos[-1].repo_name

    dir = 'HER-data/' + name + "/Data/Gazatteers/"
    file_count = Dir[File.join(dir, '**', '*')].count {|file| File.file?(file)}

    Dir.chdir 'HER-data/'


    File.open("temp" + file_count.to_s + ".txt", 'wb') {|file| file.write(data)}
    system("sed", "-i", "1,4d;$d", "temp" + file_count.to_s + ".txt")
    system("mv", "temp" + file_count.to_s + ".txt", name + "/Data/Gazatteers/")

    Dir.chdir '../'

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end
  end


  def cp_file

    data = request.body.read

    name = @user.repos[-1].id.to_s + "_" + @user.repos[-1].repo_name

    dir = 'HER-data/' + name + "/Data/Original/"
    file_count = Dir[File.join(dir, '**', '*')].count {|file| File.file?(file)}


    Dir.chdir 'HER-data/'


    File.open("temp" + file_count.to_s + ".txt", 'wb') {|file| file.write(data)}
    system("sed", "-i", "1,4d;$d", "temp" + file_count.to_s + ".txt")
    system("mv", "temp" + file_count.to_s + ".txt", name + "/Data/Original/")

    Dir.chdir '../'


    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end

  end

  def repo_directory_setup repo

    Dir.chdir "HER-data"
    name = repo.id.to_s + "_" + repo.repo_name.to_s
    system("mkdir", name)
    Dir.chdir "../HER-core"
    system('sh', 'Scripts/set_up.sh', "../HER-data/" + name)

    Dir.chdir "../"

  end

  def generate_seed

    info = JSON.parse(request.body.read)
    name = info["name"]
    file_name_array = info["fileArray"]
    gaz_name_array = info["gazArray"]

    re = find_repo name


    path = "HER-data/" + re.id.to_s + "_" + re.repo_name + "/"
    lg = re.language
    seed_size = re.seed_size.to_i

    Dir.chdir path

    index = 0
    file_name_array.each do |file_name|
      system("mv","Data/Original/temp"+index.to_s+".txt", "Data/Original/"+file_name.to_s)
      index += 1
    end


    index = 0
    gaz_name_array.each do |file_name|
      system("mv","Data/Gazatteers/temp"+index.to_s+".txt", "Data/Gazatteers/"+file_name.to_s)
      index += 1
    end



    system("sh", "Scripts/prepare_original_texts.sh", "Scripts/preprocess.py", lg, "2>", "log.txt")
    system("python", "Scripts/rankSents.py", "-corpus", "Data/Prepared/fullCorpus.txt", "-sort_method", "random_seed",
           "-topXsents", seed_size.to_s, "-output", "Data/Splits/fullCorpus.seed-" + seed_size.to_s, "-annotate", "True")

    out = `wc -l Data/Splits/*`


    status = re.status.split
    update = status[0] + " " + status[1] + " " + status[2] + " " + status[3] + " " + out.split[0] + " " + status[5] + " " + out.split[2] + " " + status[7]

    re.update(status: update)
    Dir.chdir "../.."

  end


  def add_repo

    repo_info = request.body.read

    repo_info = JSON.parse(repo_info)


    repo_name = repo_info["repo_name"]
    language = repo_info["language"]
    seed_size = repo_info["seed_size"]
    sort_method = repo_info["sort_method"]
    entities = repo_info["entities"].slice(0..-1)
    status = true
    @user.repos.each do |r|
      if r.repo_name == repo_name
        status = false
        break
      end
    end

    if status

      Repo.new(:repo_name => repo_name,
               :language => language,
               :seed_size => seed_size.to_i,
               :sort_method => sort_method,
               :entities => entities,
               :status => repo_status_initializer).save

      @user.repos << Repo.last

      repo_directory_setup Repo.last

      respond_to do |format|

        msg = {:status => true}

        format.json {render :json => msg}

      end

    else
      respond_to do |format|

        msg = {:status => false}

        format.json {render :json => msg}

      end
    end
  end

  def delete_repo

    user_info = request.body.read
    user_info = JSON.parse(user_info)
    user_info = user_info["url"].split("_")

    repo_name = user_info[1]
    re = find_repo repo_name
    folder_name = re.id.to_s + '_' + re.repo_name.to_s

    Dir.chdir "HER-data"
    system("rm", "-rf", folder_name)
    Dir.chdir "../"

    Repo.find(re.id).destroy



    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end


  end


  def share_repo

    user_info = request.body.read

    user_info = JSON.parse(user_info)

    users = user_info["users"].split
    user_repo = user_info["url"].split("_")
    username = user_repo[0]
    repo_name = user_repo[1]

    puts username
    puts users.to_s
    puts repo_name

    success_s = ""
    fail_s = ""

    re = find_repo repo_name

    users.each do |name|

      if User.find_by_username(name).blank?
        fail_s += name + " "
      else
        success_s += name + " "

        if re.users.include?(User.find_by_username(name))
        else
          re.users << User.find_by_username(name)
        end
      end
    end

    respond_to do |format|

      msg = {:success_s => success_s, :fail_s => fail_s}

      format.json {render :json => msg}

    end

  end


  def get_repo_user

    user_info = request.body.read

    user_info = JSON.parse(user_info)

    user_info = user_info["url"].split("_")

    repo_name = user_info[1]

    users = ""

    re = find_repo repo_name
    re.users.each do |u|
      users += u.username + " "
    end


    respond_to do |format|

      msg = {:username => users}

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
      User.new(:username => username, :password => password).save
    else
      status = false
    end

    respond_to do |format|

      msg = {:status => status}

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

        msg = {:status => true}

        format.json {render :json => msg}

      end


    end


  end

  private

  # Use callbacks to share common setup or constraints between actions.
    def set_user

      @user = User.find_by_username(params[:username])

    end

    def user_params
      params.require(:user).permit(:username, :password)
    end

end

