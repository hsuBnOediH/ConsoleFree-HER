class ReposController < ApplicationController
  before_action :find_and_setup_repo, except: [:temp]


  #cache sentence for each repository
  $cache = {}


  #function to display the main page
  def main
  end


  #functino to test
  def temp
  end


  #functino to send status for welcome alert
  def welcome

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}
    end
  end


  #function to update annotating cache
  def send_annotating_cache

    id = request.body.read

    $cache[$name][1] = [true, id.to_i]

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end
  end


  #function to send cache sentence for annotation
  def get_cache_sentence

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => [$cache[$name][0][$cache[$name][1][1]],$entities.split('_')]}

      format.json {render :json => msg}

    end
  end


  #function to send cache sentences
  def get_cache_data

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => $cache[$name][0]}

      format.json {render :json => msg}

    end
  end


  #function to send a sentence for annotation
  def get_sentence

    input = _helper_build_sentence

    status = true

    if $seed_status && input[2]
      $time = 1
      update_to_file
      $seed_status = false
      $line_num = 1
      $prev_line_num = 1
      @repo.update(status: update_status)

      status = false
    end

    respond_to do |format|

      msg = {:seed_status => status ,:message => "Success!",
             :sentence => input}

      format.json {render :json => msg}

    end
  end


  #function to send repository status
  def get_status

    respond_to do |format|

      msg = {:status => @repo.status.split}

      format.json {render :json => msg}

    end
  end


  #function to update sentences to file
  def update_to_file

    $cache[$name][0].each do |sentence|

      sentence.each do |line|

        system("sed", "-i", $prev_line_num.to_s+"s/^.*$/"+line+"/", $path+$sentence_path)
        $prev_line_num += 1
      end

      $prev_line_num += 1
    end

    $seed_status ? ($seed_line_annotated = $prev_line_num) : ($corpus_line_annotated = $prev_line_num)

    $cache[$name][0] = []
    $cache[$name][1] = [false, -999]

    @repo.update(status: update_status)

    if $time == 1
      return
    end

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end
  end


  #function to update an annotated sentence
  def send_sentence

    require 'json'

    upload_tag_array = request.body.read.split

    sentence = []

    upload_tag_array.each do |ele|
      json_ele = JSON.parse(ele)
      update_str = json_ele["tag"] + "\t" + json_ele["word"]
      sentence << update_str
    end

    if $cache[$name][1][0]

      $cache[$name][0][$cache[$name][1][1]] = sentence
      $cache[$name][1][0] = false
    elsif sentence.length != 0
      $cache[$name][0] << sentence
    end

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end
  end


  #functino to build input for each sentence
  def _helper_build_sentence

    input = []

    seed_finish = true

    system("cp", $path+$sentence_path, $path+"test.txt")

    if $line_num == 1
      File.readlines($path+"test.txt").each do |line|
        seed_finish = false
        # puts "*************************line 1"
        # puts line
        if line == "\n"
          break
        end
        #$line_num += 1
        $time += 1
        word_tag = line.split
        input << {word: word_tag[1], tag:word_tag[0]}
      end
    else
      system("sed", "-i", "1,"+$line_num.to_s+"d", $path+"test.txt")

      File.readlines($path+"test.txt").each do |line|
        seed_finish = false
        # puts "*************************line 2"
        # puts line
        if line == "\n"
          #$line_num += 1
          # puts "***************"+$line_num.to_s
          break
        end
        #$line_num += 1
        $time += 1
        word_tag = line.split
        input << {word: word_tag[1], tag:word_tag[0]}
      end
    end

    system("rm", $path+"test.txt")
    @repo.update(status: update_status)
    [input, $entities.split('_'), seed_finish]

  end


  #function to train and rank after annotating the seed
  def train_and_rank_seed

    Dir.chdir $path

    system("cp", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".alwaysTrain")
    system("python", "Scripts/update_gazatteers.py", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed",
           "Data/Gazatteers/*")

    system("python", "Scripts/cross_validation.py", "-testable", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed",
           "-fullCorpus", "Data/Prepared/fullCorpus.txt", "-identify_best_feats", "True", "-train_best",
           "True", "-unannotated", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated")

    system("sh", "Scripts/tag_get_final_results.sh", "0", "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod,
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".alwaysTrain", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed", "Data/Prepared/fullCorpus.txt",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.pred", "Results/fullCorpus.final.txt",
           "Results/fullCorpus.final-list.txt", "crf")
    system("cp","-r", "Data/Gazatteers", "Results/Gazatteers")
    system("cp", "-rf", "Results", "Results_seed")
    system("rm", "-rf", "Results")
    system("mkdir", "Results")

    system("sh", "Scripts/tag_and_rank.sh", "Models/CRF/best_seed.cls", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.fts",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.probs", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.fts",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed.fts", $sortMethod, "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod,
           "None", $entities)
    system("python Scripts/pre-tag_gazatteers.py Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod + " " +
               $entities+" Data/Gazatteers/* > Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod+".preTagged")
    system("mv", "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod+".preTagged",
           "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod)

    Dir.chdir $return_path

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end

  end


  #function to rank the rest of the corpus
  def generate_new_rank

    Dir.chdir $path

    system("python Scripts/pre-tag_gazatteers.py Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod + " " +
               $entities+" Data/Gazatteers/* > Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod+".preTagged")
    system("mv", "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod+".preTagged",
           "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod)

    Dir.chdir $return_path

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end
  end


  #function to evaluate
  def evaluate_inference

    lines_annotated=$prev_line_num

    Dir.chdir $path

    system("sh", "Scripts/update_crossValidate_rerank.sh", lines_annotated.to_s, "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod,
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".alwaysTrain", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed", "Data/Prepared/fullCorpus.txt", $sortMethod,
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.probs", "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod,
           $entities)
    system("python", "Scripts/update_gazatteers.py", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".alwaysTrain",
           "Data/Gazatteers/*")
    system("sh", "Scripts/tag_get_final_results.sh", lines_annotated.to_s, "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod,
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".alwaysTrain", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed", "Data/Prepared/fullCorpus.txt",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.pred", "Results/fullCorpus.final.txt",
           "Results/fullCorpus.final-list.txt", "crf")
    system("cp","-r", "Data/Gazatteers", "Results/Gazatteers")
    system("cp", "-rf", "Results", "Results_seed_plus_" + lines_annotated.to_s)
    system("rm", "-rf", "Results")
    system("mkdir", "Results")

    Dir.chdir $return_path

    $line_num = 1
    $prev_line_num = 1
    $time = 1

    @repo.update(status: update_status)

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end
  end


  #function to send cv-result, will be updated in the future
  def get_cv_result

  end


  #function to download gazatteer
  def download_gaz
    send_file($path + params[:f1] + "/" +"Gazatteers/"+ params[:file] + ".gaz")
  end


  #function to download final result
  def download_inf_result1
    send_file($path + params[:f1] + "/" + "fullCorpus.final.txt")
  end


  #function to download final result list
  def download_inf_result2
    send_file($path + params[:f1] + "/" + "fullCorpus.final-list.txt")
  end


  #function to send gazatteers information
  def get_gaz

    files = []
    Dir.each_child($path) do |x|
      if x.to_s.include?("Results_")
        Dir.each_child($path+x+"/Gazatteers/") do |f|
          files << x+"/Gazatteers/"+f
        end

      end
    end

    respond_to do |format|

      msg = {:files => files}

      format.json {render :json => msg}

    end
  end


  #function to send final result information
  def get_inf_result

    files = []
    Dir.each_child($path) do |x|
      if x.to_s.include?("Results_")
        files << x + "/fullCorpus.final.txt"
        files << x + "/fullCorpus.final-list.txt"

      end
    end

    respond_to do |format|

      msg = {:files => files}

      format.json {render :json => msg}

    end
  end


  #function to update status, for the update in the database
  def update_status

    $line_num.to_s + " " + $prev_line_num.to_s + " " + $seed_status.to_s + " " + $seed_line_annotated.to_s+
        " " + $seed_line_total.to_s + " " + $corpus_line_annotated.to_s + " " + $corpus_line_total.to_s + " " + $time.to_s
  end


  private

    #before action to set up the repository
    def find_and_setup_repo
      @user = User.find_by_username(params[:username])

      if @user.class.to_s == "NilClass"
        render :file => 'public/404.html', :status => :not_found, :layout => false
        return
      end

      @repo = "nil_repo"
      ReposUser.where("user_id='"+@user.id.to_s+"'").find_each do |repo|
        Repo.where("id='"+repo.repo_id.to_s+"'").find_each do |re|
          if re.repo_name == params[:repo_name]
            @repo = re
            break
          end
        end
      end

      if @repo == "nil_repo"
        render :file => 'public/404.html', :status => :not_found, :layout => false
        return
      end

      $name = @repo.id.to_s+"_"+@repo.repo_name
      $entities = @repo.entities
      $sortMethod = @repo.sort_method
      $lg = @repo.language
      $seed_size = @repo.seed_size.to_i

      #Retrieve from database
      status = @repo.status.split
      #$line_num = status[0].to_i
      $prev_line_num = status[1].to_i
      $seed_status = status[2] == "true"
      $seed_line_annotated = status[3].to_i
      $seed_line_total = status[4].to_i
      $corpus_line_annotated = status[5].to_i
      $corpus_line_total = status[6].to_i
      $time = status[7].to_i


      $path = "HER-data/"+$name+"/"
      $return_path = "../.."
      $seed_path = "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed"
      $corpus_path = "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod
      $seed_status ? ($sentence_path = $seed_path) : ($sentence_path = $corpus_path)

      if $cache[$name] == nil
        $cache[$name] = [[],[false,-999]]
      end

      num = 0
      $cache[$name][0].each do |line|
        num += line.length + 1
      end

      if $prev_line_num == 1
        if $cache[$name][0].length == 0
          $line_num = $prev_line_num
        else
          $line_num = $prev_line_num + num - 1
        end
      else
        $line_num = $prev_line_num + num - 1
      end

    end


end

