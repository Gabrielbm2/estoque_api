# Gemfile
gem 'jwt'

# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  has_many :products, dependent: :destroy
  has_one_attached :avatar
  
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
  enum role: { user: 'user', admin: 'admin' }, _default: 'user'
  
  def avatar_thumbnail
    return unless avatar.attached?
    
    avatar.variant(resize_to_fill: [100, 100]).processed
  end
  
  def can_modify_product?(product)
    self.admin? || product.user_id == self.id
  end
  
  # Adicionando o método para gerar JWT
  def generate_jwt
    payload = { user_id: self.id }
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end
end
