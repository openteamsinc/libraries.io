# frozen_string_literal: true

class HttpClient::Npm < HttpClient::Base
  DURATION_IN_SEC = 1

  @request_lock = RedisLock.new(name: 'npm', timeout: DURATION_IN_SEC)

  def self.head(url, options = {})
    begin
      raise unless @request_lock.acquire!
      super(url, options)
    rescue
      retry
    end
  end
end
