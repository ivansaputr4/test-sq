class Hospital < ApplicationRecord
  validates :name, presence: true
  validates :address, presence: true
  validates :area, presence: true

  # DONT CHANGE THE ORDER WITHOUT TEAM PERMISSION
  enum area: {
    south_jakarta:  1,
    north_jakarta:  2,
    west_jakarta:   3,
    east_jakarta:   4,
    bekasi:         5,
    bandung:        6,
    depok:          7,
    tangerang:      8,
    bogor:          9
  }
end
