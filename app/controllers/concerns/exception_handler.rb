module ExceptionHandler
  extend ActiveSupport::Concern

  class InvalidToken < StandardError; end

  included do
    rescue_from ExceptionHandler::InvalidToken, with: :unauthorized_token
    rescue_from JWT::DecodeError, with: :unauthorized_token
  end

  private

  def unauthorized_token(e)
    render json: { errors: e.message }, status: :unauthorized
  end
end