# frozen_string_literal: true

class HttpClient::Npm < HttpClient::Base
  DURATION = 20

  @mutex_lock = Mutex.new

  def self.head(url, options = {})
    @mutex_lock.synchronize do
      sleep duration
      super(url, options)
    end
  end

  private_class_method def self.duration(duration = DURATION)
    duration
  end
end
