class Slot < ApplicationRecord
  belongs_to :schedule

  default_scope { order(:day_of_week) }
end
