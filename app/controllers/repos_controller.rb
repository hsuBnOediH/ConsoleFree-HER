class ReposController < ApplicationController
  before_action :find_and_setup_repo, except: [:temp]

  $cache = {}

  def main

  end

  def temp

  end

  def welcome

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}
    end

  end



  def send_annotating_cache

    id = request.body.read

    $cache[$name][1] = [true, id.to_i]

  end

  def get_cache_sentence

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => [$cache[$name][0][$cache[$name][1][1]],$entities.split]}

      format.json {render :json => msg}

    end

  end

  def get_cache_data

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => $cache[$name][0]}

      format.json {render :json => msg}

    end

  end


  def get_sentence

    input = _helper_build_sentence

    status = true

    # puts input[0].length.to_s
    # puts "****************************************"

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

  def get_status

    respond_to do |format|

      msg = {:status => @repo.status.split}

      format.json {render :json => msg}

    end

  end

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
    else
      $cache[$name][0] << sentence
    end

  end



  #build input for each sentence with tracking the line number
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
        $line_num += 1
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
          $line_num += 1
          # puts "***************"+$line_num.to_s
          break
        end
        $line_num += 1
        $time += 1
        word_tag = line.split
        input << {word: word_tag[1], tag:word_tag[0]}
      end
    end

    system("rm", $path+"test.txt")
    @repo.update(status: update_status)
    [input, $entities.split, seed_finish]























    # input = []
    # puts $line_num.to_s + "************************"
    # t=0
    # system("cp", $path+$sentence_path, $path+"test.txt")
    # if $line_num != 1
    #    if $time >= 3
    #      $line_num += 1
    #    end
    #   system("sed", "-i", "1,"+$line_num.to_s+"d", $path+"test.txt")
    # end
    # $time += 1
    # File.readlines($path+"test.txt").each do |line|
    #   if (line == "\n") && (t!=0)
    #     break
    #   end
    #   t += 1
    #   $line_num += 1
    #   word_tag = line.split
    #   input << {word: word_tag[1], tag:word_tag[0]}
    # end
    # puts $line_num.to_s + "************************"
    # system("rm", $path+"test.txt")
    #
    # @repo.update(status: update_status)
    #
    # [input, $entities.split]

  end

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

  def evaluate_inference

    lines_annotated=$line_num

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

    respond_to do |format|

      msg = {:status => true}

      format.json {render :json => msg}

    end
  end

  def get_cv_result

    files = []
    Dir.each_child($path) do |x|
      if x.includes("Results_")
        Dir.each_child($path + x) do |f|

        end

      end
    end

  end

  def download_gaz
    send_file($path + params[:f1] + "/" +"Gazatteers/"+ params[:file] + ".gaz")
  end

  def download_inf_result1

    send_file($path + params[:f1] + "/" + "fullCorpus.final.txt")

  end

  def download_inf_result2

    send_file($path + params[:f1] + "/" + "fullCorpus.final-list.txt")

  end

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





  def update_status

    $line_num.to_s + " " + $prev_line_num.to_s + " " + $seed_status.to_s + " " + $seed_line_annotated.to_s+
        " " + $seed_line_total.to_s + " " + $corpus_line_annotated.to_s + " " + $corpus_line_total.to_s + " " + $time.to_s
  end

  private

    def find_and_setup_repo
      @user = User.find_by_username(params[:username])
      ReposUser.where("user_id='"+@user.id.to_s+"'").find_each do |repo|
        Repo.where("id='"+repo.repo_id.to_s+"'").find_each do |re|
          if re.repo_name == params[:repo_name]
            @repo = re
            break
          end
        end

      end

      $name = @repo.id.to_s+"_"+@repo.repo_name
      $entities = @repo.entities
      $sortMethod = @repo.sort_method
      $lg = @repo.language
      $seed_size = @repo.seed_size.to_i

      #Retrieve from database
      status = @repo.status.split
      $line_num = status[0].to_i
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
      $sentence_path = $seed_path
      $seed_status ? ($sentence_path = $seed_path) : ($sentence_path = $corpus_path)

      if $cache[$name] == nil
        $cache[$name] = [[],[false,-999]]
      end
    end

end

