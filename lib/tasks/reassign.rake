# rubocop:disable AssignmentInCondition
namespace :reassign do
  desc 'Reallocate appointment REFERENCE=x to GUIDER=x'
  task appointment: :environment do
    reference = ENV.fetch('REFERENCE')
    guider_id = ENV.fetch('GUIDER')

    if source = Appointment.find(reference)
      if guider = User.find(guider_id)
        reassign_appointment(source, guider)
      else
        puts "Could not find guider ID: #{guider_id}"
      end
    else
      puts "Could not find appointment reference: #{reference}"
    end
  end

  desc 'Attempt to reallocate appointments to random available slots from other providers'
  task random: :environment do
    appointment_ids = ENV.fetch('REFERENCES').split(',')

    appointment_ids.each do |id|
      if source = Appointment.find(id)

        if destination = BookableSlot.find_from_available_provider(source)
          reassign_appointment(source, destination.guider)
        else
          puts "Could not find any slot matching #{id}"
        end
      else
        puts "Appointment with reference #{id} was not found"
      end
    end
  end

  desc 'Attempt to reallocate appointments (REFERENCES=X,X,X) to (PROVIDER=X)'
  task appointments: :environment do
    provider_agent = User.find_by(organisation_content_id: ENV.fetch('PROVIDER'))

    appointment_ids = ENV.fetch('REFERENCES').split(',')

    appointment_ids.each do |id|
      if source = Appointment.find(id)
        destination = BookableSlot.find_available_slot(source.start_at, provider_agent)

        if destination
          reassign_appointment(source, destination.guider)
        else
          puts "Could not find an available slot matching #{id}"
        end
      else
        puts "Appointment with reference #{id} was not found"
      end
    end
  end

  def reassign_appointment(source, guider) # rubocop:disable MethodLength
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
      source.guider = guider
      source.save(validate: false)

      # create activities and notify both guiders
      Notifier.new(source).call

      puts "Reallocated: #{source.id} to: #{guider.name}"
    end
  end
end
