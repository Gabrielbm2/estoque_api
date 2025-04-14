require 'rails_helper'

RSpec.describe FileImage, type: :model do
  describe '#url' do
    let(:file) { create(:file_image, key: 'test-file.jpg', bucket: 'my-bucket') }

    before do
      allow(S3Service).to receive(:get_url).with('test-file.jpg').and_return('https://my-bucket.s3.amazonaws.com/test-file.jpg')
    end

    it 'returns the S3 URL for the file' do
      expect(file.url).to eq('https://my-bucket.s3.amazonaws.com/test-file.jpg')
      expect(S3Service).to have_received(:get_url).with('test-file.jpg')
    end
  end

  describe '#presigned_url' do
    let(:file) { create(:file_image, key: 'test-file.jpg', bucket: 'my-bucket') }
    let(:presigned_url) { 'https://my-bucket.s3.amazonaws.com/test-file.jpg?signature=abc123' }

    before do
      allow(S3Service).to receive(:presigned_url).with('test-file.jpg', expires_in: 3600).and_return(presigned_url)
    end

    it 'returns a presigned URL for the file with default expiration' do
      expect(file.presigned_url).to eq(presigned_url)
      expect(S3Service).to have_received(:presigned_url).with('test-file.jpg', expires_in: 3600)
    end

    it 'allows custom expiration time' do
      custom_expiration = 7200
      allow(S3Service).to receive(:presigned_url).with('test-file.jpg', expires_in: custom_expiration).and_return(presigned_url)
      
      expect(file.presigned_url(expires_in: custom_expiration)).to eq(presigned_url)
      expect(S3Service).to have_received(:presigned_url).with('test-file.jpg', expires_in: custom_expiration)
    end
  end
end
