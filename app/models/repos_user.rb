class ReposUser < ApplicationRecord
  belongs_to :user
  belongs_to :repo
  def find_repo_by_repo_name repo_name


  end
end
