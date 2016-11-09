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

  def update_appointment(change)
    Appointment.update(change['id'], permitted_attributes(change))
  end

  def permitted_attributes(change)
    change.slice('guider_id', 'start_at', 'end_at')
  end

  attr_reader :changes
end
