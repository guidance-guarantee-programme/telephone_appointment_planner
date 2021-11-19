class DueDiligenceReferenceNumberJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    generated_reference = DueDiligenceReferenceNumber.new(appointment).call

    appointment.update!(unique_reference_number: generated_reference)
  end
end
