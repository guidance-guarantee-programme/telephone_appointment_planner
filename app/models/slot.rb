class Slot < ApplicationRecord
  belongs_to :schedule

  default_scope { order(:day_of_week) }

  validates :day_of_week, inclusion: (1..6)
end
