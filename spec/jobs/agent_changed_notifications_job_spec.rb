require 'rails_helper'

RSpec.describe AgentChangedNotificationsJob, '#perform' do
  it 'sends notifications to the associated resource managers' do
    resource_manager = 'dave@example.com'
    appointment = double(:appointment)
    allow(appointment).to receive_message_chain(:resource_managers, :pluck).and_return([resource_manager])

    expect(AppointmentMailer).to receive(:resource_manager_appointment_changed)
      .with(appointment, resource_manager)
      .and_return(double(deliver_later: true))

    subject.perform(appointment)
  end
end
