# frozen_string_literal: true

class HttpClient::Base
  def self.head(url, options = {})
    client.head(url, options)
  end

  private_class_method def self.client
    Typhoeus
  end
end
