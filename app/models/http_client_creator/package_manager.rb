# frozen_string_literal: true

class HttpClientCreator::PackageManager
  DEFAULT_CLIENT = HttpClient::Default::PackageManager
  PLATFORMS = {
    base: DEFAULT_CLIENT,
    npm: HttpClient::Npm::PackageManager,
  }.freeze

  def self.create(platform = :base)
    PLATFORMS.fetch(platform.downcase.to_sym, DEFAULT_CLIENT)
  end
end
