require 'rails_helper'

RSpec.describe DoctorSchedule, type: :model do
  describe 'day_of_week validations' do
    context 'should be presence' do
      it 'return valid' do
        doctor_schedule = build(:doctor_schedule)
        expect(doctor_schedule.valid?).to eq(true)
      end

      it 'return invalid' do
        doctor_schedule = build(:doctor_schedule, day_of_week: '')
        expect(doctor_schedule.valid?).to eq(false)
      end
    end
  end

  describe 'schedule_session validations' do
    context 'should be presence' do
      it 'return valid' do
        doctor_schedule = build(:doctor_schedule)
        expect(doctor_schedule.valid?).to eq(true)
      end

      it 'return invalid' do
        doctor_schedule = build(:doctor_schedule, schedule_session: '')
        expect(doctor_schedule.valid?).to eq(false)
      end
    end
  end

  describe 'start_hour validations' do
    context 'should be presence' do
      it 'return valid' do
        doctor_schedule = build(:doctor_schedule)
        expect(doctor_schedule.valid?).to eq(true)
      end

      it 'return invalid' do
        doctor_schedule = build(:doctor_schedule, start_hour: '')
        expect(doctor_schedule.valid?).to eq(false)
      end
    end

    context 'should between 0-23' do
      it 'return invalid' do
        doctor_schedule = build(:doctor_schedule, start_hour: 24)
        expect(doctor_schedule.valid?).to eq(false)
      end
    end
  end

  describe 'end_hour validations' do
    context 'should be presence' do
      it 'return valid' do
        doctor_schedule = build(:doctor_schedule)
        expect(doctor_schedule.valid?).to eq(true)
      end

      it 'return invalid' do
        doctor_schedule = build(:doctor_schedule, end_hour: '')
        expect(doctor_schedule.valid?).to eq(false)
      end
    end

    context 'should between 0-23' do
      it 'return invalid' do
        doctor_schedule = build(:doctor_schedule, end_hour: 24)
        expect(doctor_schedule.valid?).to eq(false)
      end
    end

    context 'should > start_hour' do
      it 'return invalid' do
        doctor_schedule = build(:doctor_schedule, start_hour: 20, end_hour: 10)
        expect(doctor_schedule.valid?).to eq(false)
      end
    end
  end
end
