require 'rails_helper'

RSpec.describe Genesys::Models::Activity do # rubocop:disable Metrics/BlockLength
  let(:activity_hash) do
    {
      'startDate' => '2025-10-27T08:00:00Z',
      'lengthMinutes' => 120,
      'description' => '',
      'activityCodeId' => '0',
      'paid' => true
    }
  end

  subject { described_class.new(activity_hash) }

  it 'maps its basic attributes' do
    expect(subject).to have_attributes(
      start_date: Time.zone.parse('2025-10-27T08:00:00Z'),
      length_minutes: 120,
      description: '',
      activity_code_id: '0',
      paid: true
    )
  end

  describe '#to_h' do
    it 'maps back to the correct API payload' do
      expect(subject.to_h).to eq(activity_hash)
    end
  end

  describe '.from_appointment' do
    it 'maps the attributes from the provided appointment' do
      appointment = build(:appointment, start_at: Time.zone.parse('2025-12-02 13:00'))
      activity    = described_class.from_appointment(appointment)

      expect(activity).to have_attributes(
        activity_code_id: '69c595d1-a305-4be7-a3f0-bf3a8324992f',
        start_date: Time.zone.parse('2025-12-02T13:00:00Z'),
        length_minutes: 70,
        description: appointment.id.to_s,
        paid: true
      )
    end

    context 'when rescheduling' do
      it 'uses the on-queue activity code' do
        appointment = build(:appointment, start_at: Time.zone.parse('2025-12-02 13:00'))
        activity    = described_class.from_appointment(appointment, rescheduling: true)

        expect(activity.activity_code_id).to eq('0')
      end
    end
  end
end
