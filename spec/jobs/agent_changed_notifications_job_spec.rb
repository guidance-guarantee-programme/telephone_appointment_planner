require 'rails_helper'

RSpec.describe AgentChangedNotificationsJob, '#perform' do
  it 'sends notifications to the associated resource managers' do
    appointment = create(:appointment, organisation: :waltham_forest)

    expect(AppointmentMailer).to receive(:resource_manager_appointment_changed)
      .with(appointment, 'rm@example.com')
      .and_return(double(deliver_later: true))

    subject.perform(appointment)
  end
end
