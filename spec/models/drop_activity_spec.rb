require 'rails_helper'

RSpec.describe DropActivity, '.from' do
  let(:appointment) { create(:appointment) }

  before do
    allow(PusherActivityCreatedJob).to receive(:perform_later)
    allow(PusherHighPriorityCountChangedJob).to receive(:perform_later)
  end

  context 'when an email is dropped' do
    subject { described_class.from('drop', 'message', appointment) }

    it 'creates an activity entry assigned to the agent' do
      expect(subject).to have_attributes(
        appointment: appointment,
        owner: appointment.agent,
        message: 'Drop - message'
      )
    end

    it 'notifies the agent' do
      expect(PusherActivityCreatedJob).to have_received(:perform_later).with(
        appointment.agent_id,
        subject.id
      )

      expect(PusherHighPriorityCountChangedJob).to have_received(:perform_later).with(
        appointment.agent
      )
    end
  end
end
