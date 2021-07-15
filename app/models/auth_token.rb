# frozen_string_literal: true
class AuthToken < ApplicationRecord
  class RateLimitExceeded < StandardError; end

  validates_presence_of :token
  scope :authorized, -> { where(authorized: [true, nil]) }
  scope :without_rate_limit_reset_at, -> { where(rate_limit_reset_at: nil) }
  scope :resetted_rate_limit, -> { where('rate_limit_reset_at < ?', DateTime.now) }

  def self.client(options = {})
    find_token(:v3).github_client(options)
  end

  def self.v4_client
    find_token(:v4).v4_github_client
  end

  def self.token
    client.access_token
  end

  def self.create_multiple(array_of_tokens)
    array_of_tokens.each do |token|
      self.find_or_create_by(token: token)
    end
  end

  def high_rate_limit?(api_version)
    return v4_remaining_rate > 500 if api_version == :v4

    github_client.rate_limit.remaining > 500
    rescue Octokit::Unauthorized, Octokit::AccountSuspended
      false
  end

  def still_authorized?
    !!github_client.rate_limit
  rescue Octokit::Unauthorized, Octokit::AccountSuspended
    false
  end

  def github_client(options = {})
    AuthToken.new_client(token, options)
  end

  def v4_github_client
    AuthToken.new_v4_client(token)
  end

  def self.fallback_client(token = nil)
    AuthToken.new_client(token)
  end

  def self.new_client(token, options = {})
    token ||= AuthToken.token
    Octokit::Client.new({access_token: token, auto_paginate: true}.merge(options))
  end

  def self.new_v4_client(token)
    token ||= AuthToken.token
    http_adapter = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
      @@token = token

      def headers(_context)
          {
          "Authorization" => "Bearer #{@@token}"
          }
      end
    end

    # create new client with HTTP adapter set to use token and the loaded GraphQL schema
    GraphQL::Client.new(schema: Rails.application.config.graphql.schema, execute: http_adapter)
  end

  private

  def self.find_token(api_version)
    return @auth_token if @auth_token && @auth_token.high_rate_limit?(api_version)

    @auth_token = nil
    auth_token = authorized
                   .without_rate_limit_reset_at
                   .or(authorized.resetted_rate_limit)
                   .order(Arel.sql("RANDOM()")).limit(100).sample
    raise AuthToken::RateLimitExceeded if auth_token.nil?
 
    if auth_token.high_rate_limit?(api_version)
      @auth_token = auth_token
      auth_token.update(rate_limit_reset_at: nil) unless auth_token.rate_limit_reset_at.nil?
      @auth_token
    else
      reset_time = DateTime.now + AuthToken.new_client(auth_token).rate_limit.resets_in.seconds
      auth_token.update(rate_limit_reset_at: reset_time)
      find_token(api_version)
    end
  end

  def v4_remaining_rate
    query_result = v4_github_client.query(V4RateLimitQuery)
    unless query_result.data.nil?
      # check the return
      query_result.data.rate_limit.remaining
    else
      return 0
    end
  end

  V4RateLimitQuery = Rails.application.config.graphql.client.parse <<-'GRAPHQL'
    query {
      viewer {
        login
      }
      rateLimit {
        remaining
      }
    }
  GRAPHQL
end
