class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :bookings
  validates :role, inclusion: { in: ['admin', 'customer'] }

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= 'customer'
  end
end
