# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one_attached(:image) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }

    before do
      create(:product, name: 'Laptop', description: 'High performance', price: 1200, quantity: 5, user: user)
      create(:product, name: 'Mouse', description: 'Wireless mouse', price: 30, quantity: 20, user: user)
      create(:product, name: 'Keyboard', description: 'Gaming keyboard', price: 80, quantity: 10, user: user)
      create(:product, name: 'Monitor', description: 'LCD display', price: 300, quantity: 0, user: user)
    end

    describe '.search' do
      it 'returns products that match the search query in name' do
        expect(Product.search('laptop').count).to eq(1)
      end

      it 'returns products that match the search query in description' do
        expect(Product.search('wireless').count).to eq(1)
      end

      it 'returns empty collection when no matches' do
        expect(Product.search('nonexistent').count).to eq(0)
      end
    end

    describe '.price_range' do
      it 'filters products by minimum price' do
        expect(Product.price_range(100, nil).pluck(:name)).to contain_exactly('Laptop', 'Monitor')
      end

      it 'filters products by maximum price' do
        expect(Product.price_range(nil, 100).pluck(:name)).to contain_exactly('Mouse', 'Keyboard')
      end

      it 'filters products by price range' do
        expect(Product.price_range(50, 300).pluck(:name)).to contain_exactly('Keyboard', 'Monitor')
      end
    end

    describe '.in_stock' do
      it 'returns only products with quantity greater than 0' do
        expect(Product.in_stock.count).to eq(3)
        expect(Product.in_stock.pluck(:name)).not_to include('Monitor')
      end
    end

    describe '.order_by' do
      it 'orders products by price ascending' do
        ordered_products = Product.order_by('price', 'asc')
        expect(ordered_products.first.name).to eq('Mouse')
        expect(ordered_products.last.name).to eq('Laptop')
      end

      it 'orders products by quantity descending' do
        ordered_products = Product.order_by('quantity', 'desc')
        expect(ordered_products.first.name).to eq('Mouse')
        expect(ordered_products.last.name).to eq('Monitor')
      end
    end
  end

  describe 'instance methods' do
    describe '#in_stock?' do
      it 'returns true when product quantity is greater than 0' do
        product = create(:product, quantity: 5)
        expect(product.in_stock?).to be true
      end

      it 'returns false when product quantity is 0' do
        product = create(:product, quantity: 0)
        expect(product.in_stock?).to be false
      end
    end

    describe '#add_stock' do
      let(:product) { create(:product, quantity: 10) }

      it 'increases product quantity' do
        expect { product.add_stock(5) }.to change { product.quantity }.from(10).to(15)
      end

      it 'does not change quantity when adding negative amount' do
        expect { product.add_stock(-5) }.not_to(change { product.quantity })
      end
    end

    describe '#remove_stock' do
      let(:product) { create(:product, quantity: 10) }

      it 'decreases product quantity' do
        expect { product.remove_stock(5) }.to change { product.quantity }.from(10).to(5)
      end

      it 'returns false if trying to remove more than available quantity' do
        expect(product.remove_stock(15)).to be false
        expect(product.quantity).to eq(10)
      end

      it 'does not change quantity when removing negative amount' do
        expect { product.remove_stock(-5) }.not_to(change { product.quantity })
      end
    end
  end
end
