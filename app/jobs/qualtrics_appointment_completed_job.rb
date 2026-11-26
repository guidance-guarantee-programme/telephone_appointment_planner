class QualtricsAppointmentCompletedJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    return unless appointment.survey_consent?

    payload = Qualtrics::Presenters::Appointment.new(appointment).to_h

    Qualtrics::Api.new.appointment_completed(payload, pension_wise: appointment.pension_wise?)
  end
end
