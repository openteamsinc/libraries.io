# frozen_string_literal: true

class HttpClient::Npm::Base
  API_REQUEST_LOCK_DURATION = 1

  private_class_method def self.api_request_lock_acquire!
    HttpClient::RedisLock.new(name: 'npm', timeout: API_REQUEST_LOCK_DURATION).acquire!
  end
end
