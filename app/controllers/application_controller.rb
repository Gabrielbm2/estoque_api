class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def current_user
  @current_user ||= authenticate_user
  end

  before_action :authenticate_user

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last

    if token
      begin
        @decoded = JsonWebToken.decode(token)
        @current_user = User.find(@decoded[:user_id])
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    else
      render json: { errors: 'Unauthorized' }, status: :unauthorized
    end
  end

  attr_reader :current_user
end
