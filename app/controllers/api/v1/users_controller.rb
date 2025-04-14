module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show update destroy make_admin]
      before_action :authorize_admin, only: %i[index make_admin]
      before_action :authorize_user, only: %i[update destroy]

      def index
        @users = User.page(params[:page]).per(20)

        render json: {
          users: @users.map { |user| user_data(user) },
          total_count: User.count,
          current_page: @users.current_page,
          total_pages: @users.total_pages
        }
      end

      def create
        @user = User.new(user_params)

        if @user.save
          render json: {
            message: 'Usuário criado com sucesso',
            user: user_data(@user)
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        render json: { user: user_data(@user) }
      end

      def update
        if user_params[:password].blank?
          params_without_password = user_params.except(:password, :password_confirmation)
          update_success = @user.update(params_without_password)
        else
          update_success = @user.update(user_params)
        end

        if update_success
          render json: {
            message: 'Usuário atualizado com sucesso',
            user: user_data(@user)
          }
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @user.destroy
          render json: { message: 'Usuário excluído com sucesso' }
        else
          render json: { errors: 'Não foi possível excluir o usuário' }, status: :unprocessable_entity
        end
      end

      def make_admin
        if @user.update(role: 'admin')
          render json: {
            message: 'Usuário promovido a administrador com sucesso',
            user: user_data(@user)
          }, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Usuário não encontrado' }, status: :not_found
      end

      def user_params
        params.permit(:name, :email, :password, :password_confirmation, :avatar, :role)
      end

      def authorize_admin
        render json: { error: 'Você não tem permissão para realizar esta ação' }, status: :forbidden unless current_user&.admin?
      end

      def authorize_user
        render json: { error: 'Você não tem permissão para realizar esta ação' }, status: :forbidden unless @user.id == current_user.id || current_user&.admin?
      end

      def user_data(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil,
          created_at: user.created_at,
          products_count: user.products.count
        }
      end
    end
  end
end