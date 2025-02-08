require 'rails_helper'

RSpec.describe SmsFailureNotificationsJob, '#perform' do
  context 'for a regular appointment' do
    it 'sends notifications to the associated resource managers' do
      resource_manager = 'dave@example.com'
      appointment = double(:appointment).as_null_object
      allow(appointment).to receive_message_chain(:resource_managers, :pluck).and_return([resource_manager])

      expect(AppointmentMailer).to receive(:resource_manager_sms_failure)
        .with(appointment, 'supervisors@maps.org.uk')
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end
end
