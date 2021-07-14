#frozen_string_literal: true
class RepositoryUpdateStargazersCountWorker
  include Sidekiq::Worker
  sidekiq_options queue: :repo

  def perform(repo_name)
    Repository.update_stargazers_count(repo_name)
  end
end
