class GenerateBookableSlotsForUserJob < ApplicationJob
  queue_as :default

  def perform(*guiders)
    guiders.each do |guider|
      BookableSlot.generate_for_guider(guider)
    end
  end
end
