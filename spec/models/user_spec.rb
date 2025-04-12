require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'associations' do
    it { should have_many(:products).dependent(:destroy) }
    it { should have_one_attached(:avatar) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 'user', admin: 'admin').with_prefix(false) }
  end
  
  describe 'methods' do
    describe '#can_modify_product?' do
      let(:user) { create(:user) }
      let(:admin) { create(:admin) }
      let(:product) { create(:product, user: user) }
      
      it 'returns true if user is the owner of the product' do
        expect(user.can_modify_product?(product)).to be true
      end
      
      it 'returns false if user is not the owner of the product' do
        other_user = create(:user)
        expect(other_user.can_modify_product?(product)).to be false
      end
      
      it 'returns true if user is admin, regardless of ownership' do
        expect(admin.can_modify_product?(product)).to be true
      end
    end
  end
end