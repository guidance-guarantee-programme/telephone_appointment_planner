class SummaryDocumentCheckJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    return if appointment.summarised? || !appointment.complete?

    AppointmentMailer.guider_summary_document_missing(appointment).deliver_now
  end
end
