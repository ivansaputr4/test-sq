require 'rails_helper'

RSpec.describe Doctor, type: :model do
  describe 'name validations' do
    context 'should be presence' do
      it 'return valid' do
        doctor = build(:doctor)
        expect(doctor.valid?).to eq(true)
      end

      it 'return invalid' do
        doctor = build(:doctor, name: '')
        expect(doctor.valid?).to eq(false)
      end
    end
  end
end
