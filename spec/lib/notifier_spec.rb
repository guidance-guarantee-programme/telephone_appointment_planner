require 'rails_helper'

RSpec.describe Notifier, '#call' do
  subject { described_class.new(appointment) }
  let!(:appointment) { create(:appointment) }
  let(:mailer) { double }
  let(:activity) { double(id: 1) }

  before do
    allow(AppointmentMailer).to receive(:cancelled) { mailer }
    allow(AppointmentMailer).to receive(:confirmation) { mailer }
    allow(AppointmentMailer).to receive(:missed) { mailer }
    allow(AppointmentMailer).to receive(:updated) { mailer }
    allow(mailer).to receive(:deliver)
    allow(CustomerUpdateActivity).to receive(:from) { activity }
    allow(PusherActivityCreatedJob).to receive(:perform_later)
  end

  context 'when the appointment is without an associated email' do
    before do
      stub_const('AppointmentMailer', double)
      stub_const('CustomerUpdateActivity', double)
    end

    it 'does not notify the customer' do
      appointment.update_attribute(:email, '')

      subject.call
    end
  end

  context 'and I update a core detail' do
    before { appointment.update_attribute(:first_name, 'Jean Ralphio') }

    it 'sends the customer a mail' do
      expect(AppointmentMailer).to receive(:updated).with(appointment)
      subject.call
    end

    it 'creates a CustomerUpdateActvity' do
      expect(CustomerUpdateActivity)
        .to receive(:from)
        .with(appointment, CustomerUpdateActivity::UPDATED_MESSAGE)

      subject.call
    end

    context 'but the appointment was in the past' do
      before { travel_to 1.week.from_now }
      after { travel_back }

      it 'does not send customer a mail' do
        expect(AppointmentMailer).not_to receive(:updated)
        subject.call
      end

      it 'does not create a CustomerUpdateActvity' do
        expect(CustomerUpdateActivity).not_to receive(:from)
        subject.call
      end
    end
  end

  context 'and I cancel the appointment' do
    before { appointment.update_attribute(:status, 'cancelled_by_pension_wise') }

    it 'sends the customer a mail' do
      expect(AppointmentMailer).to receive(:cancelled).with(appointment)
      subject.call
    end

    it 'creates a CustomerUpdateActvity' do
      expect(CustomerUpdateActivity)
        .to receive(:from)
        .with(appointment, CustomerUpdateActivity::CANCELLED_MESSAGE)

      subject.call
    end
  end

  context 'and I mark the appointment missed' do
    before { appointment.update_attribute(:status, 'no_show') }

    it 'sends the customer a mail' do
      expect(AppointmentMailer).to receive(:missed).with(appointment)
      subject.call
    end

    it 'creates a CustomerUpdateActvity' do
      expect(CustomerUpdateActivity)
        .to receive(:from)
        .with(appointment, CustomerUpdateActivity::MISSED_MESSAGE)

      subject.call
    end
  end
end
