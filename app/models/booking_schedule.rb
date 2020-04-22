class BookingSchedule < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'

  validates :booking_date, presence: true
  validates :schedule_session, presence: true

  # amount of max patient per doctor
  MAXIMUM_PATIENT_LIMIT = 10
  # DONT CHANGE THE ORDER WITHOUT TEAM PERMISSION
  enum state: {
    booked:     1,
    confirmed:  2,
    cancelled:  3
  }
end
