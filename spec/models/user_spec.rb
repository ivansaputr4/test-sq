require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#administrator?' do
    it 'return true' do
      user = build_stubbed(:user, id: 1)
      expect(user.administrator?).to eq(true)
    end

    it 'return true' do
      user = build_stubbed(:user, id: 2)
      expect(user.administrator?).to eq(false)
    end
  end

  describe 'email validations' do
    context 'should be presence' do
      it 'return valid' do
        user = build(:user)
        expect(user.valid?).to eq(true)
      end

      it 'return invalid' do
        user = build(:user, email: '')
        expect(user.valid?).to eq(false)
      end
    end

    it { should validate_uniqueness_of(:email) }
  end

  describe 'password validations' do
    context 'should minimum length 6 characters' do
      it 'return valid' do
        user = build(:user)
        expect(user.valid?).to eq(true)
      end

      it 'return invalid' do
        user = build(:user, password: '12345')
        expect(user.valid?).to eq(false)
      end
    end
  end
end
