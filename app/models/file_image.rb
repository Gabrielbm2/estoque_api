class FileImage < ApplicationRecord
  has_many :products
  
  validates :key, presence: true, uniqueness: true
  validates :filename, presence: true
  validates :byte_size, presence: true, numericality: { greater_than: 0 }
  
  def url
    S3Service.get_url(key)
  end
  
  def presigned_url(expires_in: 3600)
    S3Service.presigned_url(key, expires_in: expires_in)
  end
end