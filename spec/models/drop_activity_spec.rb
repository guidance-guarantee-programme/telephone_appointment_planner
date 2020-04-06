require 'rails_helper'

RSpec.describe DropActivity, '.from' do
  let(:appointment) { create(:appointment) }

  before do
    allow(PusherActivityCreatedJob).to receive(:perform_later)
    allow(PusherHighPriorityCountChangedJob).to receive(:perform_later)
  end

  context 'when the initial confirmation is dropped' do
    subject { described_class.from('drop', 'message', 'booking_created', appointment) }

    it 'creates an activity entry assigned to the agent' do
      expect(subject).to have_attributes(
        appointment: appointment,
        owner: appointment.agent,
        message: 'Drop - message'
      )
    end

    it 'notifies the agent' do
      expect(PusherActivityCreatedJob).to have_received(:perform_later).with(subject.id)

      expect(PusherHighPriorityCountChangedJob).to have_received(:perform_later).with(
        appointment.agent
      )
    end
  end

  context 'for any other dropped email' do
    subject { described_class.from('drop', 'message', 'booking_missed', appointment) }

    it 'does not associate an owner' do
      expect(subject.owner).to be_nil
    end

    it 'does not issue priority notifications' do
      expect(PusherHighPriorityCountChangedJob).not_to have_received(:perform_later)
    end
  end
end
