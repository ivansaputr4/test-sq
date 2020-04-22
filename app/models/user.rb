class User < ApplicationRecord
  has_secure_password
  has_many :booking_schedules, foreign_key: 'patient_id'

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def administrator?
  	self.id == 1
  end
end
