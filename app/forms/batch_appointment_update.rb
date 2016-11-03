class BatchAppointmentUpdate
  def initialize(changes)
    @changes = JSON.parse(changes)
  end

  def call
    changes.each do |change|
      appointment = Appointment.find(change['id'])
      appointment.update!(permitted_attributes(change))
      AppointmentMailer.updated(appointment).deliver_now if appointment.email.present?
    end
  end

  private

  def permitted_attributes(change)
    change.slice('guider_id', 'start_at', 'end_at')
  end

  attr_reader :changes
end
