class ReposController < ApplicationController
  before_action :find_repo, only: [:main]

  def main

  end


  private

    def find_repo
    end
end
