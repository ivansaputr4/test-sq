class ApplicationController < ActionController::API
  before_action :authorize_request
  before_action :verify_authorization

  def not_found
    render json: failed_serializer('not found', :not_found), status: :not_found
  end

  def unauthorized
    render json: failed_serializer('unauthorized', :unauthorized), status: :unauthorized
  end

  def authorize_request
    return if controller_path == 'users' && %i[create login].include?(action_name.to_sym)
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def admin_policy
    @current_user&.administrator?
  end

  def success_serializer(data, http_status, meta = {})
    meta = meta.merge(http_status: http_status)
    {
      data: data,
      meta: meta
    }
  end

  def failed_serializer(errors, http_status)
    errors = errors.kind_of?(Array) ? errors : [errors]
    {
      errors: errors,
      meta: {
        http_status: http_status
      }
    }
  end

  def message_serializer(message, http_status)
    {
      message: message,
      meta: {
        http_status: http_status
      }
    }
  end

  private

  def verify_authorization
    unauthorized unless policy_authorize!
  end

  def policy_authorize!
    raise NotImplementedError.new('You must implement `policy_authorize!`')
  end
end
