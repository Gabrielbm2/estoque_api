module Api
  module V1
    class FileImagesController < ApplicationController
      def create
        file_data = params[:file]
        
        unless file_data && file_data.respond_to?(:content_type)
          return render json: { error: 'Nenhum arquivo enviado' }, status: :bad_request
        end
        
        unless valid_mime_type?(file_data.content_type)
          return render json: { error: 'Tipo de arquivo não suportado' }, status: :bad_request
        end
        
        begin
          file_record = S3Service.upload(file_data)
          
          render json: {
            message: 'Arquivo enviado com sucesso',
            file: {
              id: file_record.id,
              filename: file_record.filename,
              content_type: file_record.content_type,
              url: file_record.url
            }
          }, status: :created
        rescue => e
          Rails.logger.error("Erro ao fazer upload: #{e.message}")
          render json: { error: 'Erro ao fazer upload do arquivo' }, status: :unprocessable_entity
        end
      end
      
      def show
        file = FileImage.find(params[:id])
        render json: {
          file: {
            id: file.id,
            filename: file.filename,
            content_type: file.content_type,
            url: file.url
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Arquivo não encontrado' }, status: :not_found
      end
      
      def destroy
        file = FileImage.find(params[:id])
        
        if Product.where(file_image_id: file.id).exists?
          return render json: { error: 'Este arquivo está sendo usado por produtos' }, status: :unprocessable_entity
        end
        
        begin
          S3Service.delete(file.key)
          file.destroy
          
          render json: { message: 'Arquivo excluído com sucesso' }
        rescue => e
          Rails.logger.error("Erro ao excluir arquivo: #{e.message}")
          render json: { error: 'Erro ao excluir o arquivo' }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Arquivo não encontrado' }, status: :not_found
      end
      
      private
      
      def valid_mime_type?(content_type)
        allowed_types = [
          'image/jpeg', 
          'image/png', 
          'image/gif', 
          'image/webp',
          'application/pdf'
        ]
        
        allowed_types.include?(content_type)
      end
    end
  end
end