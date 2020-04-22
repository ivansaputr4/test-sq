class DoctorSchedule < ApplicationRecord
  belongs_to :doctor

  validates :day_of_week, presence: true
  validates :schedule_session, presence: true
  validates :start_hour, presence: true
  validates :end_hour, presence: true
  validate :valid_hour_range?

  # DONT CHANGE THE ORDER WITHOUT TEAM PERMISSION
  enum day_of_week: {
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 7,
  }

  private

  def valid_hour_range?
    validity = self.start_hour.present? && self.end_hour.present? && self.start_hour < self.end_hour

    unless validity
      self.errors.add(:start_hour, 'harus sebelum waktu berakhir')
      self.errors.add(:end_hour, 'harus setelah waktu mulai')
    end

    unless self.start_hour.present? && self.start_hour >= 0 && self.start_hour < 24
      self.errors.add(:start_hour, 'harus diantara 0-23')
    end

    unless self.end_hour.present? && self.end_hour >= 0 && self.end_hour < 24
      self.errors.add(:end_hour, 'harus diantara 0-23')
    end
  end
end
