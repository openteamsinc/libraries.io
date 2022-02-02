# frozen_string_literal: true

class GithubUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical, unique: :until_executed

  def perform
    redis_key = "githubuserid"
    since = REDIS.get(redis_key).to_i
    loop do
      users = AuthToken.client(auto_paginate: false).all_users(since: since)
      GithubDownloadUsersWorker.perform_async(users)
      since = users.last.id + 1
      REDIS.set(redis_key, since)
    end
  end
end
