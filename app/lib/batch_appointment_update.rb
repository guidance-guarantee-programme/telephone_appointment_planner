class BatchAppointmentUpdate
  def initialize(changes, current_user)
    @changes = JSON.parse(changes)
    @current_user = current_user
  end

  def call
    changes.each do |change|
      appointment = update_appointment(change)

      Notifier.new(appointment, @current_user).call
    end
  end

  private

  def update_appointment(change)
    appointment = Appointment.update(change['id'], permitted_attributes(change))

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
