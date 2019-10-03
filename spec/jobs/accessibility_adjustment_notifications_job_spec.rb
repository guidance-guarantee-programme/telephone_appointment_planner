require 'rails_helper'

RSpec.describe AccessibilityAdjustmentNotificationsJob, '#perform' do
  context 'when the guider is TPAS' do
    it 'sends to the supervisors mailbox' do
      resource_manager = 'test@example.org.uk'
      appointment = double(:appointment, tpas_guider?: false)
      allow(appointment).to receive_message_chain(:resource_managers, :pluck).and_return([resource_manager])

      expect(AppointmentMailer).to receive(:accessibility_adjustment)
        .with(appointment, resource_manager)
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end

  context 'when the guider is not TPAS' do
    it 'sends a notification email to associated resource managers' do
      resource_manager = 'supervisors@maps.org.uk'
      appointment      = double(:appointment, tpas_guider?: true)

      expect(AppointmentMailer).to receive(:accessibility_adjustment)
        .with(appointment, resource_manager)
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end
end
