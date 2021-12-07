# frozen_string_literal: true

class RedisLock
  attr_reader :name, :value, :timeout

  def initialize(options = {})
    @name = options.fetch(:name, 'redis_lock')
    @value = options.fetch(:value, 'value')
    @timeout = options.fetch(:timeout, 1000)
  end

  def acquire!
    Sidekiq.redis do |r|
      r.set(name, value, nx: true, ex: timeout)
    end
  end
end
