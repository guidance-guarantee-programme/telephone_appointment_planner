class GenerateBookableSlotsForUserJob < ApplicationJob
  queue_as :default

  def perform(guider)
    BookableSlot.generate_for_guider(guider)
  end
end
