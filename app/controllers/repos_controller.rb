class ReposController < ApplicationController
  before_action :find_repo, except: [:home]

  private

  def find_repo

    Repo.where("repo_name='"+params[:repo_name]+"'").find_each do|repo|

      ReposUser.where("repo_id='"+repo.id.to_s+"'" " AND user_id='"+User.find_by_username(params[:username]).id.to_s+"'").find_each do

        @repo = repo

        # $name = @repo.id.to_s+"_"+@repo.name
        # $entities = @repo.entities
        # $sortMethod = @repo.sort_method
        # $lg = @repo.language
        # $seed_size = @repo.seed_size
        #
        # #Retrieve from database
        # status = @repo.status.split
        # $line_num = status[0].to_i
        # $prev_line_num = status[1].to_i
        # $seed_status = status[2]
        # $seed_line_annotated = status[3].to_i
        # $seed_line_total = status[4].to_i
        # $corpus_line_annotated = status[5].to_i
        # $corpus_line_total = status[6].to_i
        # $time = status[7].to_i
        #
        # $path = "HER-data/"+$name+"/"
        # $return_path = "../.."
        # $seed_path = "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed"
        # $corpus_path = "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod
        #
        # $seed_status ? ($sentence_path = $seed_path) : ($sentence_path = $corpus_path)
        #
        # $cache_data = []
        # $annotating_cache = [false, -999]

        break
      end
    end

  end

  def main

  end

  def home

  end

  def send_annotating_cache

    id = request.body.read

    $annotating_cache = [true, id.to_i]

  end

  def get_cache_sentence

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => [$cache_data[$annotating_cache[1]],$entities.split]}

      format.json {render :json => msg}

    end

  end

  def get_cache_data

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => $cache_data}

      format.json {render :json => msg}

    end

  end


  def check_end_condition

  end

  def get_sentence

    input = _helper_build_sentence

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => input}

      format.json {render :json => msg}

    end

  end

  def get_status

    respond_to do |format|

      msg = {:status => "ok", :message => "Success!",
             :sentence => [$seed_status, $seed_line_annotated, $seed_line_total,
                           $corpus_line_annotated, $corpus_line_total]}

      format.json {render :json => msg}

    end

  end

  def update_to_file

    $cache_data.each do |sentence|

      sentence.each do |line|

        system("sed", "-i", $prev_line_num.to_s+"s/^.*$/"+line+"/", $path+$sentence_path)
        $prev_line_num += 1

      end

      $prev_line_num += 1
    end

    $seed_status ? ($seed_line_annotated = $prev_line_num) : ($corpus_line_annotated = $prev_line_num)

    $cache_data = []

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

    if $annotating_cache[0]
      $cache_data[$annotating_cache[1]] = sentence
      $annotating_cache[0] = false
    else
      $cache_data << sentence
    end

  end




  #recieve the data and put it in the specific folder
  def upload
    data = request.body.read
    File.open("db/temp.txt", 'wb') { |file| file.write(data) }
    system("sed", "-i", "1,4d;$d", "db/temp.txt")
    setup_repo
    system("mv", "db/temp.txt", $path+"Data/Original/")

    generate_seed

  end

  #build input for each sentence with tracking the line number
  def _helper_build_sentence

    input = []
    system("cp", $path+$sentence_path, "db/test.txt")
    if $line_num != 1
      if $time >= 3
        $line_num += 1
      end
      system("sed", "-i", "1,"+$line_num.to_s+"d", "db/test.txt")
    end
    $time += 1
    File.readlines('db/test.txt').each do |line|
      if line == "\n"
        break
      end
      $line_num += 1
      word_tag = line.split
      input << {word: word_tag[1], tag:word_tag[0]}
    end
    system("rm", "db/test.txt")

    [input, $entities.split]

  end






  def setup_repo

    Dir.chdir "db/HER-master"

    system("mkdir", $name)
    system('sh', 'Scripts/set_up.sh', $name)
    system("cp", "Data/Gazatteers/GEO.gaz", $name + "/Data/Gazatteers/GEO.gaz")

    Dir.chdir "../.."

  end

  def generate_seed

    Dir.chdir $path

    system("sh", "Scripts/prepare_original_texts.sh","Scripts/preprocess.py", $lg, "2>", "log.txt")
    system("python","Scripts/rankSents.py","-corpus","Data/Prepared/fullCorpus.txt","-sort_method","random_seed",
           "-topXsents",$seed_size.to_s,"-output","Data/Splits/fullCorpus.seed-"+$seed_size.to_s, "-annotate", "True")

    out = `wc -l Data/Splits/*`

    $seed_line_total = out.split[0].to_i
    $corpus_line_total = out.split[2].to_i

    Dir.chdir $return_path

  end

  def feature_engineering_and_train

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

    Dir.chdir $return_path

    rank_and_annotate

  end

  def rank_and_annotate

    Dir.chdir $path

    system("sh", "Scripts/tag_and_rank.sh", "Models/CRF/best_seed.cls", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.fts",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.probs", "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".unannotated.fts",
           "Data/Splits/fullCorpus.seed-"+$seed_size.to_s+".seed.fts", $sortMethod, "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod,
           "None", $entities)
    system("python Scripts/pre-tag_gazatteers.py Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod + " " +
               $entities+" Data/Gazatteers/* > Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod+".preTagged")
    system("mv", "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod+".preTagged",
           "Models/RankedSents/fullCorpus.seed-"+$seed_size.to_s+"."+$sortMethod)

    Dir.chdir $return_path

  end

  def inference_and_evaluate

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

  end




end
