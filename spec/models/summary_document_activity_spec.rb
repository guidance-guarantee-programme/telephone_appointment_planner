require 'rails_helper'

RSpec.describe SummaryDocumentActivity do
  before do
    allow(PusherActivityCreatedJob).to receive(:perform_later)
  end

  let(:user) { create(:user) }
  let(:message) { 'message' }
  let(:params) do
    {
      user: user,
      owner: appointment.try(:guider),
      appointment: appointment,
      message: message
    }
  end

  describe 'validation' do
    subject { described_class.new(params) }

    context 'if the appointment is not present' do
      let(:appointment) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'if the appointment is present' do
      let(:appointment) { create(:appointment) }

      context 'but the appointment does not allow creation of a summary' do
        before { allow(appointment).to receive(:can_create_summary?) { false } }

        it { is_expected.not_to be_valid }
      end

      context 'and the appointment allows creation of a summary' do
        before { allow(appointment).to receive(:can_create_summary?) { true } }

        it { is_expected.to be_valid }
      end
    end
  end

  describe '.create' do
    let(:appointment) { create(:appointment) }
    before { allow(appointment).to receive(:can_create_summary?) { true } }
    subject { described_class.create!(params) }

    context 'and the appointment allows creation of a summary' do
      it 'creates a create activity for the given appointment and message' do
        expect(subject).to be_a(described_class)

        expect(subject).to have_attributes(
          appointment_id: appointment.id,
          owner_id: appointment.guider.id,
          user_id: user.id,
          message: message
        )
      end

      it 'pushes an activity update' do
        expect(PusherActivityCreatedJob).to have_received(:perform_later).with(subject.id)
      end
    end
  end
end
