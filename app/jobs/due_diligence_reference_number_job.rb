class DueDiligenceReferenceNumberJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::RecordInvalid, wait: 1.second, attempts: 3

  def perform(appointment)
    generated_reference = DueDiligenceReferenceNumber.new(appointment).call

    appointment.update!(unique_reference_number: generated_reference)
  end
end
