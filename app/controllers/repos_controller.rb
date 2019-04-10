class ReposController < ApplicationController
  before_action :find_repo, only: [:main]

  def main

  end


  private

  def find_repo

    Repo.where("repo_name='"+params[:repo_name]+"'").find_each do|repo|

      ReposUser.where("repo_id='"+repo.id.to_s+"'" " AND user_id='"+params[:id].to_s+"'").find_each do

        @repo = repo
        break
      end
    end

  end

end
