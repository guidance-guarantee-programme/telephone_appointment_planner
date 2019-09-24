require 'rails_helper'

RSpec.describe AccessibilityAdjustmentNotificationsJob, '#perform' do
  it 'sends a notification email to associated resource managers' do
    resource_manager = double(:resource_manager)
    appointment      = double(:appointment, resource_managers: Array(resource_manager))

    expect(AppointmentMailer).to receive(:accessibility_adjustment)
      .with(appointment, resource_manager)
      .and_return(double(deliver_later: true))

    subject.perform(appointment)
  end
end
