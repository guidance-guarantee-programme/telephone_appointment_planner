class SlotRange < ApplicationRecord
  belongs_to :user
  has_many :slots, inverse_of: :slot_range, dependent: :destroy
  accepts_nested_attributes_for :slots, allow_destroy: true
end
