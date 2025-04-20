class AuditLog < ApplicationRecord
  belongs_to :booking
  validates :action, presence: true
  validates :timestamp, presence: true
end
