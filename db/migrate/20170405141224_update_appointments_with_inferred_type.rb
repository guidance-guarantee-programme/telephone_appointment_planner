class UpdateAppointmentsWithInferredType < ActiveRecord::Migration[5.0]
  def up
    Appointment.without_auditing do
      Appointment.find_each do |appointment|
        # clear this so it's inferred again from the age / date of birth
        appointment.type_of_appointment = ''

        appointment.update_attribute(:type_of_appointment, appointment.type_of_appointment)
      end
    end
  end

  def down
    # noop
  end
end
