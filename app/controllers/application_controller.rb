class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  class ResourceForbiddenError < StandardError; end

  rescue_from ResourceForbiddenError do |_error|
    render json: { errors: { 'resource': ['is forbidden'] } }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do |_error|
    render json: { errors: 'Record not found' }, status: :not_found
  end

  def current_user
    @current_user ||= User.find_by(token: token)
  end

  private

  def token_match
    return if token && current_user

    render json: { errors: { token: ['is invalid'] } }, status: :unauthorized
  end

  def token
    request.headers['Authorization']
  end
end
