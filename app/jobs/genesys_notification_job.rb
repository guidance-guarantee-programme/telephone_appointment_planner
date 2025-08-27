class GenesysNotificationJob < ApplicationJob
  def perform(event_data)
    event = JSON.parse(event_data)

    return unless (genesys_operation_id = event.dig('eventBody', 'operationId'))

    appointment = Appointment.find_by(genesys_operation_id:)
    return process_push_completion(appointment, event) if appointment

    appointment = Appointment.find_by(genesys_rescheduling_operation_id: genesys_operation_id)
    process_rescheduling(appointment, event) if appointment
  end

  private

  def process_push_completion(appointment, event)
    message = if generation_failed?(event)
                'The appointment could not be synchronised with Genesys'
              else
                'The appointment was synchronised with Genesys'
              end

    GenesysProcessedActivity.create!(appointment:, message:)
  end

  def process_rescheduling(appointment, event)
    return if generation_failed?(event)

    Genesys::Push.new(appointment).call
  end

  def generation_failed?(event)
    event.dig('eventBody', 'result', 'generationResults', 'failed')
  end
end
