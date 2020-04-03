namespace :reassign do
  desc 'Attempt to reallocate appointments (REFERENCES=X,X,X) to (PROVIDER=X)'
  task appointments: :environment do
    provider_agent = User.find_by(organisation_content_id: ENV.fetch('PROVIDER'))

    appointment_ids = ENV.fetch('REFERENCES').split(',')

    appointment_ids.each do |id|
      if source = Appointment.find(id) # rubocop:disable AssignmentInCondition
        destination = BookableSlot.find_available_slot(source.start_at, provider_agent)

        if destination
          ActiveRecord::Base.transaction do
            # block the underlying slot
            Holiday.create!(
              title: 'Reallocation block',
              user: source.guider,
              start_at: source.start_at,
              end_at: source.end_at,
              bank_holiday: false
            )

            # reallocate the appointment to the new guider
            source.guider = destination.guider
            source.save(validate: false)

            # create activities and notify both guiders
            Notifier.new(source).call

            puts "Reallocated: #{id} to: #{source.guider.name}"
          end
        else
          puts "Could not find an available slot matching #{id}"
        end
      else
        puts "Appointment with reference #{id} was not found"
      end
    end
  end
end
