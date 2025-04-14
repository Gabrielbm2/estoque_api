require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }

  path '/api/v1/users' do
    get('lista usuários') do
      security [bearerAuth: []]
      description 'Retorna uma lista de todos os usuários cadastrados no sistema.'
      tags 'Usuários'
      produces 'application/json'

      response(200, 'successful') do
        let(:Authorization) { "Bearer #{create(:user, role: 'admin').generate_jwt}" }

        run_test!
      end
    end

    post('cria um usuário') do
      description 'Cria um novo usuário no sistema com as informações fornecidas.'
      tags 'Usuários'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: %w[name email password password_confirmation]
      }

      response(201, 'successful') do
        let(:user) { { name: 'João', email: 'joao@example.com', password: '123456', password_confirmation: '123456' } }

        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'ID único do usuário'

    get('pesquisa um usuário pelo seu ID') do
      security [bearerAuth: []]
      description 'Retorna informações detalhadas de um usuário específico.'
      tags 'Usuários'
      produces 'application/json'

      response(200, 'successful') do
        let(:user) { create(:user) }
        let(:id) { user.id }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }

        run_test!
      end
    end

    patch('atualiza parcialmente um usuário pelo seu ID') do
      security [bearerAuth: []]
      description 'Atualiza parcialmente as informações de um usuário existente.'
      tags 'Usuários'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string }
        }
      }

      response(200, 'successful') do
        let(:user_record) { create(:user) }
        let(:id) { user_record.id }
        let(:Authorization) { "Bearer #{user_record.generate_jwt}" }
        let(:user) { { name: 'Novo Nome' } }

        run_test!
      end
    end

    put('atualiza um usuário pelo seu ID') do
      security [bearerAuth: []]
      description 'Substitui completamente as informações de um usuário existente.'
      tags 'Usuários'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string }
        },
        required: %w[name email]
      }

      response(200, 'successful') do
        let(:user_record) { create(:user) }
        let(:id) { user_record.id }
        let(:Authorization) { "Bearer #{user_record.generate_jwt}" }
        let(:user) { { name: 'Nome Atualizado', email: 'atualizado@example.com' } }

        run_test!
      end
    end

    delete('deleta um usuário pelo seu ID') do
      security [bearerAuth: []]
      description 'Remove permanentemente um usuário do sistema.'
      tags 'Usuários'
      produces 'application/json'

      response(200, 'successful') do
        let(:user_record) { create(:user) }
        let(:id) { user_record.id }
        let(:Authorization) { "Bearer #{user_record.generate_jwt}" }

        run_test!
      end
    end
  end

    path '/api/v1/users/{id}/make_admin' do
    patch('promover usuário a administrador') do
      security [bearerAuth: []]
      description 'Define a role de um usuário como administrador. Apenas administradores podem executar esta ação.'
      tags 'Usuários'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'ID único do usuário'

      response(200, 'successful') do
        let(:admin) { create(:user, role: 'admin') }
        let(:user) { create(:user, role: 'user') }
        let(:id) { user.id }
        let(:Authorization) { "Bearer #{admin.generate_jwt}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user']['role']).to eq('admin')
        end
      end

      response(403, 'forbidden - usuário não é administrador') do
        let(:non_admin) { create(:user, role: 'user') }
        let(:user) { create(:user, role: 'user') }
        let(:id) { user.id }
        let(:Authorization) { "Bearer #{non_admin.generate_jwt}" }

        run_test!
      end

      response(404, 'not found - usuário não encontrado') do
        let(:admin) { create(:user, role: 'admin') }
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{admin.generate_jwt}" }

        run_test!
      end
    end
  end
end