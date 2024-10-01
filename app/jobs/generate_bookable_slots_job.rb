class GenerateBookableSlotsJob < ApplicationJob
  queue_as :default

  def perform
    BookableSlot.generate_for_booking_window
  end
end
