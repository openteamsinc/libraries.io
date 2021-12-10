# frozen_string_literal: true

class HttpClient::Npm::PackageManager < HttpClient::Npm::Base
  def self.get(url, options = {})
    raise HttpClient::ResourceLockedError unless api_request_lock_acquire!

    client(url, options).get
  rescue HttpClient::ResourceLockedError
    retry
  end

  private_class_method def self.client(url, options = {})
    Faraday.new url.strip, options do |builder|
      builder.use FaradayMiddleware::Gzip
      builder.use FaradayMiddleware::FollowRedirects, limit: 3
      builder.request :retry, { max: 2, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2 }

      builder.use :instrumentation
      builder.adapter :typhoeus
    end
  end
end
