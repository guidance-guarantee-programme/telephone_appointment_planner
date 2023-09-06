require 'rails_helper'

RSpec.describe DropForm, '#create_activity' do
  let(:appointment) { create(:appointment) }
  let(:params) do
    {
      'event'          => 'dropped',
      'description'    => 'the reasoning',
      'appointment_id' => appointment.to_param,
      'environment'    => 'production',
      'message_type'   => 'booking_created',
      'timestamp'      => '1474638633',
      'token'          => 'secret',
      'signature'      => 'abf02bef01e803bea52213cb092a31dc2174f63bcc2382ba25732f4c84e084c1'
    }
  end
  let(:token) { 'deadbeef' }

  around do |example|
    begin
      existing = ENV['MAILGUN_API_TOKEN']

      ENV['MAILGUN_API_TOKEN'] = token
      example.run
    ensure
      ENV['MAILGUN_API_TOKEN'] = existing
    end
  end

  subject { described_class.new(params) }

  context 'when the signature is not verified' do
    it 'raises an error' do
      params['signature'] = 'whoops'

      expect { subject.create_activity }.to raise_error(TokenVerificationFailure)
    end
  end

  context 'when the signature is verified' do
    it 'requires production environment' do
      params['environment'] = 'staging'

      expect(subject).not_to be_valid
    end

    it 'requires an event' do
      params.delete('event')

      expect(subject).not_to be_valid
    end

    it 'requires an appointment' do
      params['appointment_id'] = '999'

      expect { subject.create_activity }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'requires a message type' do
      params.delete('message_type')

      expect(subject).not_to be_valid
    end

    DropForm::IGNORED_MESSAGE_TYPES.each do |type|
      it "does not bounce for `#{type}` messages" do
        params['message_type'] = type

        expect(subject).to be_invalid
      end
    end

    context 'when everything is validated' do
      it 'creates the drop activity and enqueues the notifications zob' do
        expect(DropActivity).to receive(:from).with(
          params['event'],
          params['description'],
          params['message_type'],
          appointment
        )

        expect(EmailDropNotificationsJob).to receive(:perform_later).with(appointment)

        subject.create_activity
      end
    end
  end
end
