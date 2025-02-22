RailsPerformance.setup do |config|
  # config.redis = Redis::Namespace.new("#{Rails.env}-rails-performance", redis: Redis.new)
  config.redis = Redis.new(host: "redis")
  config.duration = 4.hours

  config.debug = false # currently not used>
  config.enabled = true

  # default path where to mount gem
  config.mount_at = '/rails/performance'

  # protect your Performance Dashboard with HTTP BASIC password
  config.http_basic_authentication_enabled = true
  config.http_basic_authentication_user_name = ENV["RAILS_PERFORMANCE_USERNAME"]
  config.http_basic_authentication_password = ENV["RAILS_PERFORMANCE_PASSWORD"]

  # if you need an additional rules to check user permissions
  config.verify_access_proc = proc { |controller| true }
  # for example when you have `current_user`
  # config.verify_access_proc = proc { |controller| controller.current_user && controller.current_user.admin? }

  # You can ignore endpoints with Rails standard notation controller#action
  # config.ignored_endpoints = ['HomeController#contact']
end if defined?(RailsPerformance)
