class Openteams::ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: e.to_s }, status: :not_found
  end
  
  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, fast_api_token)
    end
  end

  def fast_api_token
    ENV['OPENTEAMS_API_TOKEN']
  end
end
