require 'rails_helper'

RSpec.describe EmailDropNotificationsJob, '#perform' do
  context 'for a regular appointment' do
    it 'sends notifications to the associated resource managers' do
      resource_manager = 'dave@example.com'
      appointment = double(:appointment, email: 'bob@example.com')
      allow(appointment).to receive_message_chain(:resource_managers, :pluck).and_return([resource_manager])

      expect(AppointmentMailer).to receive(:resource_manager_email_dropped)
        .with(appointment, resource_manager)
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end

  context 'for an appointment placed by a resource manager' do
    it 'ensures an email loop is never created' do
      resource_manager = 'dave@example.com'
      appointment = double(:appointment, email: resource_manager)
      allow(appointment).to receive_message_chain(:resource_managers, :pluck).and_return([resource_manager])

      expect(AppointmentMailer).to_not receive(:resource_manager_email_dropped)

      subject.perform(appointment)
    end
  end
end
