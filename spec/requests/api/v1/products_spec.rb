require 'swagger_helper'

RSpec.describe 'api/v1/products', type: :request do
  let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }

  path '/api/v1/products/{id}/update_stock' do
  parameter name: 'id', in: :path, type: :string, description: 'ID do produto'
  parameter name: 'quantity_change', in: :body, schema: {
    type: :object,
    properties: {
      quantity_change: { type: :integer }
    },
    required: ['quantity_change']
  }

  post('estoque atualizado com sucesso') do
    security [bearerAuth: []]
    description 'Atualiza o estoque de um produto específico.'
    tags 'Produtos'

    response(200, 'successful') do
      let(:product) { create(:product, quantity: 100) }
      let(:id) { product.id }
      let(:quantity_change) { 10 }

      after do |example|
        if response.nil?
          puts "A resposta é nil!"
        else
          puts "Status da resposta: #{response.status}"
          if response.status == 200
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          else
            example.metadata[:response][:content] = {
              'application/json' => { error: "Expected JSON, got #{response.body}" }
            }
          end
        end
      end

      run_test!
    end
  end
end


  path '/api/v1/products' do
    get('lista os produtos') do
      security [bearerAuth: []]
      description 'Retorna uma lista de todos os produtos disponíveis no sistema.'
      tags 'Produtos'
      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

  post('criação do produto') do
    security [bearerAuth: []]
    description 'Cria um novo produto no sistema com as informações fornecidas.'
    tags 'Produtos'
    consumes 'application/json'

    parameter name: :body, in: :body, schema: {
      type: :object,
      properties: {
        name: { type: :string, description: 'Nome do produto' },
        description: { type: :string, description: 'Descrição detalhada do produto' },
        price: { type: :number, description: 'Preço unitário do produto' },
        quantity: { type: :integer, description: 'Quantidade inicial em estoque' },
        file_image_id: { type: :integer, description: 'ID do arquivo de imagem associado ao produto' },
        user_id: { type: :integer, description: 'ID do usuário que está criando o produto (necessário para associar o produto ao usuário)', required: true }
      },
      required: ['name', 'price', 'quantity', 'user_id']
    }

    response(201, 'Produto criado com sucesso') do
      let(:user) { create(:user) }
      let(:file_image) { create(:file_image) }

      let(:Authorization) { "Bearer #{user.generate_jwt}" }

      let(:body) do
        {
          name: 'Produto Teste',
          description: 'Descrição teste',
          price: 9.99,
          quantity: 10,
          file_image_id: file_image.id,
          user_id: user.id
        }
      end

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      run_test!
      end
    end
  end

path '/api/v1/products/{id}' do
  parameter name: 'id', in: :path, type: :string, description: 'ID único do produto'

  get('pesquisa o produto pelo ID') do
    security [bearerAuth: []]
    description 'Retorna informações detalhadas de um produto específico.'
    tags 'Produtos'

    response(200, 'successful') do
      let(:file_image) { create(:file_image) }
      let(:product) { create(:product, file_image: file_image) }
      let(:id) { product.id }

      after do |example|
        if response.nil?
          puts "A resposta é nil!"
        else
          puts "Status da resposta: #{response.status}"
          if response.status == 200
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          else
            example.metadata[:response][:content] = {
              'application/json' => { error: "Expected JSON, got #{response.body}" }
            }
          end
        end
      end

      run_test!
    end
  end

    patch('atualiza parcialmente o produto pelo ID') do
      security [bearerAuth: []]
      description 'Atualiza parcialmente as informações de um produto existente.'
      tags 'Produtos'
      consumes 'application/json'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: 'Nome do produto' },
          description: { type: :string, description: 'Descrição detalhada do produto' },
          price: { type: :number, description: 'Preço unitário do produto' },
          quantity: { type: :integer, description: 'Quantidade inicial em estoque' },
          file_image_id: { type: :integer, description: 'ID do arquivo de imagem associado ao produto' }
        },
      }

      response(200, 'Produto atualizado com sucesso') do
        let(:id) { '123' }
        let(:body) do
          {
            name: 'Novo Nome',
            price: 19.99
          }
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end

    put('atualiza o produto pelo ID') do
      security [bearerAuth: []]
      description 'Substitui completamente as informações de um produto existente.'
      tags 'Produtos'
      consumes 'application/json'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, description: 'Nome do produto' },
          description: { type: :string, description: 'Descrição detalhada do produto' },
          price: { type: :number, description: 'Preço unitário do produto' },
          quantity: { type: :integer, description: 'Quantidade inicial em estoque' },
          file_image_id: { type: :integer, description: 'ID do arquivo de imagem associado ao produto' }
        },
      }

      response(200, 'Produto atualizado com sucesso') do
        let(:id) { '123' }
        let(:body) do
          {
            name: 'Nome Completo',
            description: 'Descrição atualizada',
            price: 29.99,
            quantity: 5,
            file_image_id: nil,
          }
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end

    delete('deleta o produto pelo ID') do
      security [bearerAuth: []]
      description 'Remove permanentemente um produto do sistema.'
      tags 'Produtos'
      response(200, 'Produto excluído com sucesso') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

    path '/api/v1/users/{user_id}/products' do
    get 'Lista os produtos do usuário' do
      tags 'Products'
      produces 'application/json'
      parameter name: :user_id, in: :path, type: :string, description: 'ID do usuário'
      parameter name: :Authorization, in: :header, type: :string

      response '200', 'Produtos retornados com sucesso' do
        let(:user) { create(:user) }
        let(:user_id) { user.id }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }

        run_test!
      end
    end
  end
end