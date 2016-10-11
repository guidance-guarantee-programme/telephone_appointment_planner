class GenerateBookableSlotsJob < ApplicationJob
  queue_as :default

  def perform
    BookableSlot.generate_for_six_weeks
  end
end
