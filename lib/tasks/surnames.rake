namespace :surnames do
  desc 'Correct surnames'
  task correct: :environment do
    Appointment.without_auditing do
      Appointment.where.not(last_name: 'redacted').find_each do |appointment|
        appointment.last_name = CapitalizeNames.capitalize(appointment.last_name)

        if appointment.last_name_changed?
          change = appointment.last_name_change

          appointment.save(validate: false)

          puts "Changed from '#{change.first}' to '#{change.last}'"
        end
      end
    end
  end
end
