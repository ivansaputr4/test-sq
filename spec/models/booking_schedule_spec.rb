require 'rails_helper'

RSpec.describe BookingSchedule, type: :model do
  describe 'booking_date validations' do
    context 'should be presence' do
      it 'return valid' do
        booking_schedule = build(:booking_schedule)
        expect(booking_schedule.valid?).to eq(true)
      end

      it 'return invalid' do
        booking_schedule = build(:booking_schedule, booking_date: '')
        expect(booking_schedule.valid?).to eq(false)
      end
    end
  end

  describe 'schedule_session validations' do
    context 'should be presence' do
      it 'return valid' do
        booking_schedule = build(:booking_schedule)
        expect(booking_schedule.valid?).to eq(true)
      end

      it 'return invalid' do
        booking_schedule = build(:booking_schedule, schedule_session: '')
        expect(booking_schedule.valid?).to eq(false)
      end
    end
  end
end
