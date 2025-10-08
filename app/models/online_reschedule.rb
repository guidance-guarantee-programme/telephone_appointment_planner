class OnlineReschedule < ApplicationRecord
  belongs_to :appointment
  belongs_to :previous_guider, class_name: 'User'
end
