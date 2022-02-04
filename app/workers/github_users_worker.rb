# frozen_string_literal: true

class GithubUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical, unique: :until_executed

  def perform
    redis_key = "githubuserid"
    since = REDIS.get(redis_key).to_i
    10.times.with_index do |index|
      users = AuthToken.client(auto_paginate: false).all_users(since: since).map(&:to_h)
      GithubDownloadUsersWorker.perform_at(index.hour, users)
      since = users.last[:id].to_i + 1
      REDIS.set(redis_key, since)
    end
  end
end
