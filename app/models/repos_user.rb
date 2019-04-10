class ReposUser < ApplicationRecord
  belongs_to :user
  belongs_to :repo

  def find_repo_by_repo_name user_id,repo_name
    ReposUser.all.each do |line|
      if line.user_id == user_id
        re = Repo.find_by_id(line.repo_id)
        if re.repo_name == repo_name
          return re
        end
      end
    end



  end
end
