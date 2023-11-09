require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AdjustmentNotificationsJob, '#perform' do
  context 'when the guider is CAS' do
    it 'sends to their alias' do
      resource_manager = 'CAS_PWBooking@cas.org.uk'
      appointment      = double(:appointment, cas_guider?: true, tpas_guider?: false)

      expect(AppointmentMailer).to receive(:adjustment)
        .with(appointment, resource_manager)
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end

  context 'when the guider is not TPAS' do
    it 'sends to the associated resource managers' do
      resource_manager = 'test@example.org.uk'
      appointment = double(:appointment, tpas_guider?: false, cas_guider?: false)
      allow(appointment).to receive_message_chain(:resource_managers, :pluck).and_return([resource_manager])

      expect(AppointmentMailer).to receive(:adjustment)
        .with(appointment, resource_manager)
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end

  context 'when the guider is TPAS' do
    it 'sends to the configured alias' do
      resource_manager = 'supervisors@maps.org.uk'
      appointment      = double(:appointment, tpas_guider?: true)

      expect(AppointmentMailer).to receive(:adjustment)
        .with(appointment, resource_manager)
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end
end
# rubocop:enable Metrics/BlockLength
