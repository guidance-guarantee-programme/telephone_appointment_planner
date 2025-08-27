require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Genesys::Models::Shift do
  let(:shift_hash) do
    {
      'id' => '0',
      'startDate' => '2025-10-27T08:00:00Z',
      'lengthMinutes' => 660,
      'activities' => [
        {
          'startDate' => '2025-10-27T08:00:00Z',
          'lengthMinutes' => 120,
          'description' => '',
          'activityCodeId' => '0',
          'paid' => true
        },
        {
          'startDate' => '2025-10-27T10:00:00Z',
          'lengthMinutes' => 120,
          'description' => '',
          'activityCodeId' => '0',
          'paid' => true
        }
      ],
      'manuallyEdited' => false
    }
  end

  subject { described_class.new(shift_hash) }

  it 'maps its basic attributes' do
    expect(subject).to have_attributes(
      id: '0',
      start_date: Time.zone.parse('2025-10-27T08:00:00Z'),
      length_minutes: 660,
      manually_edited: false
    )
  end

  it 'infers the `#end_date`' do
    expect(subject.end_date).to eq(Time.zone.parse('2025-10-27 19:00:00 +0000'))
  end

  describe '#create_activity' do
    context 'when successful' do
      let(:activity) { Genesys::Models::Activity.new('startDate' => '2025-10-27T11:00:00Z', 'lengthMinutes' => 70) }

      before { subject.create_activity(activity) }

      it 'assigns the activity to the shift' do
        expect(subject.activities).to include(activity)
      end

      it 'marks the shift as manually edited' do
        expect(subject).to be_manually_edited
      end
    end

    context 'when an existing activity would leave gaps after removal' do
      let(:activity) { Genesys::Models::Activity.new('startDate' => '2025-10-27T08:00:00Z', 'lengthMinutes' => 70) }

      it 'fills the remaining gaps with `onqueue` activities' do
        subject.create_activity(activity)

        _first, filler, _third = *subject.activities

        expect(filler).to have_attributes(
          start_date: Time.zone.parse('2025-10-27 09:10'),
          length_minutes: 50
        )
      end
    end

    context 'when an addition would leave a gap from the start or end of the shift' do
      subject do
        Genesys::Models::Shift.new(
          'id' => 1,
          'startDate' => '2026-01-01T08:00:00Z',
          'lengthMinutes' => 180,
          'manuallyEdited' => false,
          'activities' => [
            {
              'startDate' => '2026-01-01T08:00:00Z',
              'lengthMinutes' => 60,
              'description' => '',
              'activityCodeId' => '0',
              'paid' => true
            },
            {
              'startDate' => '2026-01-01T09:00:00Z',
              'lengthMinutes' => 60,
              'description' => '',
              'activityCodeId' => '0',
              'paid' => true
            },
            {
              'startDate' => '2026-01-01T10:00:00Z',
              'lengthMinutes' => 60,
              'description' => '',
              'activityCodeId' => '0',
              'paid' => true
            }
          ]
        )
      end

      it 'fills the starting gap with an `onqueue` activity' do
        activity = Genesys::Models::Activity.new(
          'startDate' => '2026-01-01T08:30:00Z',
          'lengthMinutes' => 30,
          'description' => '',
          'activityCodeId' => '123'
        )

        subject.create_activity(activity)

        expect(subject.activities.first).to have_attributes(
          start_date: Time.zone.parse('2026-01-01T08:00:00Z'),
          length_minutes: 30,
          activity_code_id: '0'
        )
      end

      it 'fills the ending gap with an `onqueue` activity' do
        activity = Genesys::Models::Activity.new(
          'startDate' => '2026-01-01T10:00:00Z',
          'lengthMinutes' => 30,
          'description' => '',
          'activityCodeId' => '123'
        )

        subject.create_activity(activity)

        expect(subject.activities.last).to have_attributes(
          start_date: Time.zone.parse('2026-01-01T10:30:00Z'),
          length_minutes: 30,
          activity_code_id: '0'
        )
      end
    end
  end

  describe '#covers?' do
    context 'when the provided activity can be assigned to the shift' do
      it 'returns true' do
        activity = double(Genesys::Models::Activity, start_date: Time.zone.parse('2025-10-27T10:00:00Z'))

        expect(subject.covers?(activity)).to be_truthy
      end
    end

    context 'when the provided activity cannot be assigned to the shift' do
      it 'returns false' do
        activity = double(Genesys::Models::Activity, start_date: Time.zone.parse('2025-10-28T10:00:00Z'))

        expect(subject.covers?(activity)).to be_falsy
      end
    end
  end

  describe '#overlapping_activities' do
    context 'when the schedule’s activities are empty' do
      it 'returns an empty array' do
        shift_hash['activities'] = []

        activity = double(Genesys::Models::Activity, start_date: Time.zone.parse('2025-10-28T10:00:00Z'))

        expect(subject.overlapping_activities(activity)).to eq([])
      end
    end

    context 'when none overlap' do
      it 'returns an empty array' do
        activity = Genesys::Models::Activity.new(
          'startDate' => '2025-10-30T10:00:00Z',
          'lengthMinutes' => 70
        )

        expect(subject.overlapping_activities(activity)).to eq([])
      end
    end

    context 'when one activity overlaps' do
      it 'returns an array containing the overlapping activity' do
        activity = Genesys::Models::Activity.new(
          'startDate' => '2025-10-27T08:00:00Z',
          'lengthMinutes' => 70
        )

        expect(subject.overlapping_activities(activity)).to eq([subject.activities.first])
      end
    end

    context 'when multiple activities overlap' do
      it 'returns an array containing all overlapping activities' do
        activity = Genesys::Models::Activity.new(
          'startDate' => '2025-10-27T09:30:00Z',
          'lengthMinutes' => 70
        )

        expect(subject.overlapping_activities(activity)).to eq(subject.activities)
      end
    end
  end

  it 'has `activities`' do
    expect(subject.activities.first).to be_an_instance_of(Genesys::Models::Activity)
  end

  describe '#to_h' do
    it 'maps back the required API attributes' do
      expect(subject.to_h).to eq(shift_hash)
    end
  end
end
# rubocop:enable Metrics/BlockLength
