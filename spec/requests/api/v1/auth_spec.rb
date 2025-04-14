require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/login' do
    post('Login realizado com sucesso') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      response(200, 'successful') do
        let(:user) { create(:user, password: '123456') }
        let(:credentials) do
          {
            email: user.email,
            password: '123456'
          }
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:credentials) do
          { email: 'wrong@example.com', password: 'wrongpassword' }
        end

        run_test!
      end
    end
  end

  path '/api/v1/register' do
    post('registrar auth') do
      description 'Registra um novo usuário no sistema e retorna um token de autenticação.'
      tags 'Autenticação'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'João Silva', description: 'Nome completo do usuário' },
          email: { type: :string, example: 'joao@example.com', description: 'Email único do usuário (será usado para login)' },
          password: { type: :string, example: 'securepass', description: 'Senha com pelo menos 6 caracteres' },
          password_confirmation: { type: :string, example: 'securepass', description: 'Confirmação da senha (deve ser igual à senha)' }
        },
        required: %w[name email password password_confirmation]
      }

      response(201, 'Usuário criado com sucesso') do
        let(:user) do
          {
            name: 'João Silva',
            email: 'joao@example.com',
            password: 'securepass',
            password_confirmation: 'securepass'
          }
        end

        run_test!
      end

      response(422, 'Dados inválidos') do
        let(:user) do
          {
            name: '',
            email: 'invalido',
            password: '123',
            password_confirmation: '456'
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/me' do
    get 'Usuário autenticado' do
      tags 'Auth'
      security [bearer_auth: []]
      produces 'application/json'

      let(:user) { create(:user, password: '123456') }
      let(:token) { JsonWebToken.encode(user_id: user.id) }
      let(:authorization) { "Bearer #{token}" }

      response '401', 'Usuário autenticado' do

        run_test!
      end

      response '401', 'Não autorizado' do
        let(:authorization) { nil }
        run_test!
      end
    end
  end
end
