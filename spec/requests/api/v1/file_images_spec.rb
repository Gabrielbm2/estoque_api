require 'swagger_helper'
require 'tempfile'

RSpec.describe 'api/v1/file_images', type: :request do
  path '/api/v1/file_images' do
    post('Cria um novo arquivo') do
      tags 'Arquivos'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :file, in: :formData, type: :file, required: true, description: 'Arquivo a ser enviado (JPEG, PNG, GIF, WEBP ou PDF)'

      response(201, 'Arquivo enviado com sucesso') do
        let(:temp_file) do
          file = Tempfile.new(['test', '.pdf'])
          file.write("Este é um conteúdo de teste do arquivo PDF.")
          file.rewind
          file
        end

        let(:file) { Rack::Test::UploadedFile.new(temp_file.path, 'application/pdf') }
        let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }

        before do
          allow(S3Service).to receive(:upload).and_return(
            create(:file_image)
          )
          allow(S3Service).to receive(:get_url).and_return('http://example.com/test.pdf')
        end

        after do
          temp_file.close
          temp_file.unlink
        end

        run_test!
      end

      response(400, 'Nenhum arquivo enviado ou tipo inválido') do
        let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }
        let(:file) { nil }

        run_test!
      end

      response(401, 'Usuário não autenticado') do
        let(:temp_file) do
          file = Tempfile.new(['test', '.pdf'])
          file.write("Este é um conteúdo de teste do arquivo PDF.")
          file.rewind
          file
        end

        let(:file) { Rack::Test::UploadedFile.new(temp_file.path, 'application/pdf') }
        let(:Authorization) { nil }

        after do
          temp_file.close
          temp_file.unlink
        end

        run_test!
      end
    end
  end

  path '/api/v1/file_images/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'ID do arquivo'
    
    get('Retorna detalhes do arquivo') do
      security [bearerAuth: []]
      tags 'Arquivos'
      produces 'application/json'

      response(200, 'Arquivo encontrado') do
        let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }
        let(:id) { create(:file_image).id }

        before do
          allow(S3Service).to receive(:get_url).and_return('http://example.com/test.pdf')
        end

        run_test!
      end

      response(404, 'Arquivo não encontrado') do
        let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }
        let(:id) { 'nonexistent' }

        run_test!
      end
    end

    delete('Exclui um arquivo') do
      tags 'Arquivos'
      security [bearerAuth: []]
      produces 'application/json'

      response(200, 'Arquivo excluído com sucesso') do
        let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }
        let(:id) { create(:file_image).id }

        before do
          allow(S3Service).to receive(:delete).and_return(true)
          allow(S3Service).to receive(:get_url).and_return('http://example.com/test.pdf')
        end

        run_test!
      end

      response(422, 'Arquivo está sendo usado por produtos') do
        let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }
        let(:id) { create(:file_image_in_use).id }

        before do
          allow(S3Service).to receive(:get_url).and_return('http://example.com/test-used.pdf')
        end

        run_test!
      end

      response(404, 'Arquivo não encontrado') do
        let(:Authorization) { "Bearer #{create(:user).generate_jwt}" }
        let(:id) { 'nonexistent' }

        run_test!
      end
    end
  end
end