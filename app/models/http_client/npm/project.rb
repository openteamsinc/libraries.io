# frozen_string_literal: true

class HttpClient::Npm::Project < HttpClient::Npm::Base
  def self.head(url, options = {})
    raise HttpClient::ResourceLockedError unless api_request_lock_acquire!

    client.head(url, options)
  rescue HttpClient::ResourceLockedError
    retry
  end

  private_class_method def self.client
    Typhoeus
  end
end
