require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Schedule, type: :model do
  describe 'validation' do
    context 'with valid attributes' do
      it 'is valid' do
        expect(build(:schedule)).to be_valid
      end
    end

    it 'validates presence of start_at' do
      expect(build(:schedule, start_at: nil)).to_not be_valid
    end

    it 'has unique start_at, per user' do
      same_time = Time.zone.now
      same_user = create(:guider)
      create(
        :schedule,
        user: same_user,
        start_at: same_time
      )

      schedule = build(
        :schedule,
        user: same_user,
        start_at: same_time
      )
      expect(schedule).to_not be_valid

      schedule.user = create(:guider)
      expect(schedule).to be_valid
    end
  end

  describe '#modifiable?' do
    context 'schedule has ended' do
      it 'is false' do
        user = create(:user)
        create(:schedule, user:, start_at: 5.days.ago)
        create(:schedule, user:, start_at: 3.days.ago)
        schedule = Schedule.with_end_at.first
        expect(schedule).to_not be_modifiable
      end
    end

    context 'schedule has not ended' do
      it 'is true' do
        schedule = build_stubbed(:schedule, start_at: 1.day.from_now)
        expect(schedule).to be_modifiable
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
