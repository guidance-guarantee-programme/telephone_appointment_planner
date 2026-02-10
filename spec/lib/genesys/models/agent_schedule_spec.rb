require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Genesys::Models::AgentSchedule do
  let(:agent_schedules_hash) do
    {
      'user' => {
        'id' => '17cf0981-df81-4407-9bac-fedca56c8755',
        'selfUri' => '/api/v2/users/17cf0981-df81-4407-9bac-fedca56c8755'
      },
      'shifts' => [
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
            }
          ],
          'manuallyEdited' => true,
          'workPlanShiftId' => '0'
        }
      ],
      'fullDayTimeOffMarkers' => [],
      'metadata' => { 'version' => 1 }
    }
  end

  subject { described_class.new(agent_schedules_hash) }

  it 'maps `fullDayTimeOffMarkers`' do
    expect(subject.full_day_time_off_markers).to eq([])
  end

  describe '#to_h' do
    it 'maps to the correct API payload' do
      expect(subject.to_h).to eq(
        {
          'userId' => '17cf0981-df81-4407-9bac-fedca56c8755',
          'fullDayTimeOffMarkers' => [],
          'metadata' => { 'version' => 1 },
          'shifts' => [
            {
              'id' => '0',
              'startDate' => '2025-10-27T08:00:00Z',
              'lengthMinutes' => 660,
              'manuallyEdited' => true,
              'activities' => [
                {
                  'startDate' => '2025-10-27T08:00:00Z',
                  'lengthMinutes' => 120,
                  'description' => '',
                  'activityCodeId' => '0',
                  'paid' => true
                }
              ]
            }
          ],
          'manuallyEdited' => true
        }
      )
    end
  end

  describe '#user' do
    it 'is a user' do
      expect(subject.user).to be_an_instance_of(Genesys::Models::User)
    end
  end

  describe '#shifts' do
    it 'is an array of shifts' do
      expect(subject.shifts.first).to be_an_instance_of(Genesys::Models::Shift)
    end
  end

  describe '#metadata' do
    it 'is a metadata' do
      expect(subject.metadata).to be_an_instance_of(Genesys::Models::Metadata)
    end
  end

  describe '#assign_activity' do
    context 'when no matching shift exists' do
      it 'returns false' do
        activity = double(Activity, start_date: Time.zone.parse('2025-10-28T12:00:00Z'))

        expect(subject.assign_activity(activity)).to be_falsy
      end
    end

    context 'when a matching shift exists' do
      it 'modifies the shift' do
        activity = double(
          Activity,
          start_date: Time.zone.parse('2025-10-27T12:00:00Z'),
          length_minutes: 70,
          end_date: Time.zone.parse('2025-10-27T13:10:00Z'),
          date_range: (nil..nil)
        )

        expect(subject.assign_activity(activity)).to be_truthy
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
