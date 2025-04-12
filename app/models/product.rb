class Product < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  scope :search, ->(query) { 
    where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") if query.present? 
  }
  
  scope :price_range, ->(min, max) {
    range = {}
    range[:minimum] = min.to_f if min.present?
    range[:maximum] = max.to_f if max.present?
    
    products = self
    products = products.where("price >= ?", range[:minimum]) if range[:minimum]
    products = products.where("price <= ?", range[:maximum]) if range[:maximum]
    
    products
  }
  
  scope :in_stock, -> { where("quantity > 0") }
  
  scope :order_by, ->(field, direction = 'asc') {
    direction = %w[asc desc].include?(direction.downcase) ? direction : 'asc'
    field = %w[name price quantity created_at].include?(field) ? field : 'created_at'
    order("#{field} #{direction}")
  }
  
  def in_stock?
    quantity > 0
  end
  
  def add_stock(amount)
    update(quantity: quantity + amount) if amount.positive?
  end
  
  def remove_stock(amount)
    return false if amount > quantity
    update(quantity: quantity - amount) if amount.positive?
  end
  
  def image_thumbnail
    return unless image.attached?
    
    image.variant(resize_to_fill: [400, 400]).processed
  end
  
  def as_json(options = {})
    super(options).merge(
      image_url: image.attached? ? Rails.application.routes.url_helpers.url_for(image) : nil,
      user_name: user.name
    )
  end
end