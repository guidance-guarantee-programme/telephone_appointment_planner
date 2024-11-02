require 'rails_helper'

RSpec.describe Casebook::Api do
  let(:client) { double }
  let(:token) { double }

  before do
    allow(client).to receive_message_chain('client_credentials.get_token') { token }
  end

  subject { described_class.new(client:) }

  context 'when pushing a valid appointment' do
    it 'returns the casebook appointment identifier' do
      appointment = build(:appointment_for_casebook_creation)

      expect(token).to receive(:post).with(
        '/api/v1/appointments',
        params: {
          data: {
            attributes: {
              channel: 'telephone',
              date_of_birth: '1945-01-01',
              email: 'someone@example.com',
              ends_at: '2024-02-22T14:00:00Z',
              first_name: 'Daisy',
              last_name: 'George',
              location_id: 26_089,
              mobile_phone: '07715930444',
              notes: "Pension Wise online booking ##{appointment.id}.",
              starts_at: '2024-02-22T13:00:00Z',
              user_id: 90_939
            }
          }
        }
      ).and_return(
        double(parsed: {
                 'data' => {
                   'id' => '123456',
                   'attributes' => { 'case-reference-number' => 'CA-1010101' }
                 }
               })
      )

      response = subject.create(appointment)

      expect(response.appointment_id).to eq('123456')
      expect(response.case_reference_number).to eq('CA-1010101')
    end
  end

  context 'when cancelling an appointment' do
    it 'destroys the appointment' do
      appointment = build(:appointment_for_casebook_cancellation)

      expect(token).to receive(:delete).with(
        '/api/v1/appointments/1',
        params: {
          data: {
            attributes: {
              cancel_status: 'customer_cancelled'
            }
          }
        }
      ).and_return(true)

      expect(subject.cancel(appointment)).to be_truthy
    end
  end

  context 'when rescheduling an existing appointment' do
    it 'reschedules the appointment' do
      appointment = build(:appointment_for_casebook_creation, :casebook_pushed, :pension_wise_rescheduled)

      expect(token).to receive(:post).with(
        '/api/v1/appointments/1/reschedule',
        params: {
          data: {
            attributes: {
              channel: 'telephone',
              date_of_birth: '1945-01-01',
              email: 'someone@example.com',
              ends_at: '2024-02-22T14:00:00Z',
              first_name: 'Daisy',
              last_name: 'George',
              location_id: 26_089,
              mobile_phone: '07715930444',
              notes: "Pension Wise online booking ##{appointment.id}.",
              starts_at: '2024-02-22T13:00:00Z',
              user_id: 90_939,
              reschedule_status: 'office_rescheduled'
            }
          }
        }
      ).and_return(
        double(parsed: {
                 'data' => {
                   'id' => '123456',
                   'attributes' => { 'case-reference-number' => 'CA-1010101' }
                 }
               })
      )

      response = subject.reschedule(appointment)

      expect(response.appointment_id).to eq('123456')
      expect(response.case_reference_number).to eq('CA-1010101')
    end
  end
end
