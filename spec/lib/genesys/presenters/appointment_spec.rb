require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Genesys::Presenters::Appointment do
  let(:appointment) { create(:appointment, :genesys_guider) }

  describe '#guider' do
    context 'when not rescheduling' do
      subject { described_class.new(appointment, rescheduling: false) }

      it 'returns the current guider' do
        expect(subject.guider).to eq(appointment.guider)
      end
    end

    context 'when rescheduling' do
      subject { described_class.new(appointment, rescheduling: true) }

      it 'returns the previous guider' do
        @previous_guider = appointment.guider

        appointment.update!(
          guider: create(:guider),
          rescheduling_reason: 'office_rescheduled',
          rescheduling_route: 'unplanned_absence'
        )

        expect(subject.guider).to eq(@previous_guider)
      end
    end
  end

  describe '#start_at' do
    context 'when rescheduling' do
      subject { described_class.new(appointment, rescheduling: true) }

      context 'during BST' do
        it 'is shifted an hour to allow for timezone differences' do
          travel_to '2026-06-01 13:00' do
            appointment.update!(
              start_at: appointment.start_at.change(hour: 18),
              end_at: appointment.end_at.change(hour: 19),
              rescheduling_reason: 'office_rescheduled',
              rescheduling_route: 'unplanned_absence'
            )

            expect(subject.start_at).to eq(Time.zone.parse('2026-06-04 11:00'))
          end
        end
      end

      context 'during GMT' do
        it 'is not shifted' do
          travel_to '2025-11-05 13:00' do
            appointment.update!(
              start_at: appointment.start_at.change(hour: 18),
              end_at: appointment.end_at.change(hour: 19),
              rescheduling_reason: 'office_rescheduled',
              rescheduling_route: 'unplanned_absence'
            )

            expect(subject.start_at).to eq(Time.zone.parse('2025-11-10 12:00'))
          end
        end
      end
    end

    context 'when not rescheduling' do
      subject { described_class.new(appointment, rescheduling: false) }

      context 'during BST' do
        it 'is shifted an hour to allow for timezone differences' do
          travel_to '2026-06-01 13:00' do
            expect(subject.start_at).to eq(Time.zone.parse('2026-06-04 11:00'))
          end
        end
      end

      context 'during GMT' do
        it 'is not shifted' do
          travel_to '2025-11-05 13:00' do
            expect(subject.start_at).to eq(Time.zone.parse('2025-11-10 12:00'))
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
