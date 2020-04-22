require 'rails_helper'

RSpec.describe Hospital, type: :model do
  describe 'name validations' do
    context 'should be presence' do
      it 'return valid' do
        hospital = build(:hospital)
        expect(hospital.valid?).to eq(true)
      end

      it 'return invalid' do
        hospital = build(:hospital, name: '')
        expect(hospital.valid?).to eq(false)
      end
    end
  end

  describe 'address validations' do
    context 'should be presence' do
      it 'return valid' do
        hospital = build(:hospital)
        expect(hospital.valid?).to eq(true)
      end

      it 'return invalid' do
        hospital = build(:hospital, address: '')
        expect(hospital.valid?).to eq(false)
      end
    end
  end

  describe 'area validations' do
    context 'should be presence' do
      it 'return valid' do
        hospital = build(:hospital)
        expect(hospital.valid?).to eq(true)
      end

      it 'return invalid' do
        hospital = build(:hospital, area: '')
        expect(hospital.valid?).to eq(false)
      end
    end
  end
end
