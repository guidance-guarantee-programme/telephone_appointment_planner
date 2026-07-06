require 'rails_helper'

RSpec.describe Genesys::Services::PublishedScheduleAppointmentSynchroniser, '#call' do
  it 'pushes each appointment in the list to Genesys' do
    appointment = double(Appointment)
    pusher = double(Genesys::Push, call: true)

    allow(Genesys::Push).to receive(:new).with(appointment).and_return(pusher)

    described_class.new(Array(appointment)).call

    expect(pusher).to have_received(:call)
  end

  context 'when an appointment could not be published due to missing schedule' do
    it 'reports the underlying error to bugsnag' do
      appointment = double(Appointment)
      pusher = double(Genesys::Push)

      allow(Bugsnag).to receive(:notify)
      allow(Genesys::Push).to receive(:new).with(appointment).and_return(pusher)
      allow(pusher).to receive(:call).and_raise(Genesys::PublishedScheduleMissingError)

      described_class.new(Array(appointment)).call

      expect(Bugsnag).to have_received(:notify)
    end
  end
end
