class BatchAppointmentUpdate
  def initialize(changes)
    @changes = JSON.parse(changes)
  end

  def call
    changes.each do |change|
      appointment = update_appointment(change)

      Notifier.new(appointment).call
    end
  end

  private

  def update_appointment(change) # rubocop:disable Metrics/MethodLength
    appointment = Appointment.find(change['id'])
    attributes  = permitted_attributes(change).merge(
      previous_guider_id: appointment.guider_id.dup,
      previous_start_at: appointment.start_at.dup
    )

    appointment.update(attributes)

    if appointment.invalid?
      Rails.logger.info('Allocations calendar batch failure')
      Rails.logger.info(appointment.errors.full_messages)
    end

    appointment
  end

  def permitted_attributes(change)
    change.slice('guider_id', 'start_at', 'end_at', 'rescheduling_reason', 'rescheduling_route')
  end

  attr_reader :changes
end
