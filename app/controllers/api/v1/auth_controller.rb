# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user, only: %i[login register]

      def login
        @user = User.find_by(email: params[:email])

        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: @user.id)
          time = Time.now + 24.hours.to_i

          render json: {
            token: token,
            exp: time.strftime('%Y-%m-%d %H:%M'),
            user: user_data(@user)
          }, status: :ok
        else
          render json: { error: 'Email ou senha inválidos' }, status: :unauthorized
        end
      end

      def register
        @user = User.new(user_params)

        if @user.save
          token = JsonWebToken.encode(user_id: @user.id)
          time = Time.now + 24.hours.to_i

          render json: {
            message: 'Usuário criado com sucesso',
            token: token,
            exp: time.strftime('%Y-%m-%d %H:%M'),
            user: user_data(@user)
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def me
        render json: { user: user_data(current_user) }, status: :ok
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation, :avatar)
      end

      def user_data(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil,
          created_at: user.created_at
        }
      end
    end
  end
end
