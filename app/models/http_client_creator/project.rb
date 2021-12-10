# frozen_string_literal: true

class HttpClientCreator::Project
  DEFAULT_CLIENT = Typhoeus
  PLATFORMS = {
    base: DEFAULT_CLIENT,
    npm: HttpClient::Npm::Project,
  }.freeze

  def self.create(platform = :base)
    PLATFORMS.fetch(platform.downcase.to_sym, DEFAULT_CLIENT)
  end
end
