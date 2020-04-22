class Doctor < ApplicationRecord
	has_many :doctor_schedules
  has_many :booking_schedules

  validates :name, presence: true

  # DONT CHANGE THE ORDER WITHOUT TEAM PERMISSION
  enum specialist: {
    general:          1,
    tht:              2,
    internal_disease: 3,
    dentist:          4,
    Obstetricians:    5
  }
end
