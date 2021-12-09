# frozen_string_literal: true

class HttpClient::Default::PackageManager
  def self.get(url, options = {})
    client(url, options).get
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
