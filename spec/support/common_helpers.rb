module CommonHelpers
  module Requests
    def api_host!
      host! "api.local.host:3000"
    end

    def auth_token(current_user)
      payload = {}
      payload[:user_id] = current_user.id
      payload[:exp] = 1.hour.from_now.to_i
      token = JWT.encode(payload, Rails.application.secrets.secret_key_base.to_s)

      { 'Authorization' => token }
    end

    def json_header
      { 'ACCEPT' => 'application/json' }
    end

    def headers(options = {})
      headers = {}
      headers.merge!(json_header)
      headers.merge!(auth_token(current_user)) if respond_to?(:current_user)
      headers
    end

    def do_request(method)
      http_params  = respond_to?(:http_params) ? send(:http_params) : {}
      public_send(method, http_path, params: http_params, headers: headers)
    end
  end
end

RSpec.configure do |config|
  config.include CommonHelpers::Requests, type: :request
end
