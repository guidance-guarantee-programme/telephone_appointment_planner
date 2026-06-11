require 'rails_helper'

RSpec.describe BatchAppointmentUpdate, '#call' do # rubocop:disable Metrics/BlockLength
  let(:new_guider) { create(:guider) }
  let(:new_slot) { create(:bookable_slot, guider: new_guider, start_at: appointment.start_at) }
  let(:appointment) { create(:appointment) }

  subject do
    described_class.new(
      [
        {
          id: appointment.id,
          guider_id: new_guider.id,
          start_at: new_slot.start_at,
          end_at: new_slot.end_at,
          rescheduling_reason: 'office_rescheduled',
          rescheduling_route: 'unplanned_absence'
        }
      ].to_json
    )
  end

  it 'updates all changed attributes' do
    @previous_guider_id = appointment.guider_id.dup
    @previous_start_at  = appointment.start_at.dup

    subject.call

    expect(appointment.reload).to have_attributes(
      start_at: new_slot.start_at,
      end_at: new_slot.end_at,
      rescheduling_reason: 'office_rescheduled',
      rescheduling_route: 'unplanned_absence',
      previous_guider_id: @previous_guider_id,
      previous_start_at: @previous_start_at
    )
  end
end
