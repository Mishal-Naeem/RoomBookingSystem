class Room < ApplicationRecord
  has_many :bookings
  validates :name, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than: 0 }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
end
