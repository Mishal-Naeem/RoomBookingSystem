class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, inclusion: { in: ['pending', 'confirmed', 'cancelled'] }
  validates :total_price, numericality: { greater_than: 0 }

  validate :room_availability, on: :create

  before_save :calculate_total_price

  def room_availability
    overlapping_bookings = Booking.where(room: room)
                                  .where("start_time < ? AND end_time > ?", end_time, start_time)
                                  .where.not(id: id)
    if overlapping_bookings.exists?
      errors.add(:base, "Room #{room.name} is not available during the selected time slot. It overlaps with an existing booking.")
    end
  end

  def calculate_total_price
    duration = (end_time - start_time) / 1.hour
    if duration <= 0
      errors.add(:base, 'Start time must be before end time.')
      return
    end

    discount = duration > 4 ? 0.1 : 0 
    self.total_price = (room.price_per_hour * duration) * (1 - discount)

    if total_price.nil? || total_price <= 0
      errors.add(:total_price, 'is not a valid number')
    end
  end
end
