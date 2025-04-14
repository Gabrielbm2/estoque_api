module Api
  module V1
    class ProductsController < ApplicationController
      before_action :set_product, only: %i[show update destroy]
      before_action :authorize_product, only: %i[update destroy]

      def index
        @products = if params[:user_id] == 'me' || params[:user_id].to_s == current_user.id.to_s
                      current_user.products
                    elsif params[:user_id].present?
                      User.find(params[:user_id]).products
                    else
                      Product.all
                    end

        @products = apply_filters(@products)
        @products = apply_sorting(@products)
        @products = apply_pagination(@products)

        total_count = @products.count

        render json: {
          products: @products.map { |product| product_data(product) },
          meta: {
            total_count: total_count,
            page: (params[:page] || 1).to_i,
            per_page: (params[:per_page] || 10).to_i,
            total_pages: (total_count.to_f / (params[:per_page] || 10).to_i).ceil
          }
        }
      end

      def show
        render json: { product: product_data(@product) }
      end

      def create
    @product = current_user.products.new(product_params)  # Associando o produto ao usuário autenticado

        if @product.save
          render json: @product, status: :created
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          render json: {
            message: 'Produto atualizado com sucesso',
            product: product_data(@product)
          }
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @product.destroy
          render json: { message: 'Produto excluído com sucesso' }
        else
          render json: { errors: 'Não foi possível excluir o produto' }, status: :unprocessable_entity
        end
      end

      def update_stock
        @product = Product.find(params[:id])
        authorize_product

        quantity_change = params[:quantity_change].to_i
        new_quantity = @product.quantity + quantity_change

        if new_quantity.negative?
          render json: { error: 'Quantidade em estoque insuficiente' }, status: :unprocessable_entity
          return
        end

        if @product.update(quantity: new_quantity)
          render json: {
            message: 'Estoque atualizado com sucesso',
            product: product_data(@product)
          }
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.permit(:name, :description, :price, :quantity, :image, :file_image_id)
      end

      def authorize_product
        return if @product.user_id == current_user.id || current_user.admin?

        render json: { error: 'Você não tem permissão para realizar esta ação' }, status: :forbidden
      end

      def apply_filters(products)
        filtered_products = products

        filtered_products = filtered_products.search(params[:search]) if params[:search].present?

        filtered_products = filtered_products.where('price >= ?', params[:min_price]) if params[:min_price].present?

        filtered_products = filtered_products.where('price <= ?', params[:max_price]) if params[:max_price].present?

        if params[:in_stock].present? && params[:in_stock] == 'true'
          filtered_products = filtered_products.where('quantity > 0')
        end

        filtered_products
      end

      def apply_sorting(products)
        if params[:order_by].present?
          field = params[:order_by]
          direction = %w[asc desc].include?(params[:direction].to_s.downcase) ? params[:direction] : 'asc'

          return products.order("#{field} #{direction}") if %w[name price quantity created_at].include?(field)
        end

        products.order(created_at: :desc)
      end

      def apply_pagination(products)
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i

        products.limit(per_page).offset((page - 1) * per_page)
      end

      def product_data(product)
        {
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          quantity: product.quantity,
          user_id: product.user_id,
          user_name: product.user.name,
          image_url: product.image_url,
          file_image_id: product.file_image_id,
          created_at: product.created_at,
          updated_at: product.updated_at
        }
      end
    end
  end
end