require 'aws-sdk-s3'

class S3Service
  class << self
    def bucket
      @bucket ||= begin
        s3 = Aws::S3::Resource.new(
          region: ENV['AWS_REGION'],
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
        )
        s3.bucket(ENV['AWS_BUCKET'])
      end
    end
    
    def client
      @client ||= Aws::S3::Client.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
    end
    
    def upload(file_data, key = nil)
      key ||= generate_unique_key(file_data.original_filename)
      
      bucket.object(key).upload_file(
        file_data.tempfile.path,
        content_type: file_data.content_type
      )
      
      create_file_record(
        key: key,
        filename: file_data.original_filename,
        content_type: file_data.content_type,
        byte_size: file_data.size,
        bucket: ENV['AWS_BUCKET']
      )
    end
    
    def delete(key)
      bucket.object(key).delete
    end
    
    def get_url(key)
      "https://#{ENV['AWS_BUCKET']}.s3.#{ENV['AWS_REGION']}.amazonaws.com/#{key}"
    end
    
    def presigned_url(key, expires_in: 3600)
      bucket.object(key).presigned_url(:get, expires_in: expires_in)
    end
    
    private
    
    def generate_unique_key(filename)
      extension = File.extname(filename)
      base_name = File.basename(filename, extension)
      timestamp = Time.now.to_i
      random_string = SecureRandom.hex(8)
      
      "#{base_name}-#{timestamp}-#{random_string}#{extension}"
    end
    
    def create_file_record(attributes)
      ::File.create!(attributes)
    end
  end
end