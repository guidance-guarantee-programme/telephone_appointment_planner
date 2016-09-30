require 'rails_helper'

RSpec.describe Schedule, type: :model do
  describe 'validation' do
    context '#from' do
      context 'first schedule' do
        let(:user) do
          create(:user)
        end

        def build_schedule(from)
          build(:schedule, user: user, from: from)
        end

        it 'can have any from date' do
          expect(build_schedule(Time.zone.now)).to be_valid
        end

        it 'is not nil' do
          expect(build_schedule(nil)).to_not be_valid
        end
      end

      context 'not first schedule' do
        let(:user) do
          user = create(:user)
          user.schedules << build(:schedule)
          user.reload
          user
        end

        def build_schedule(from)
          build(:schedule, user: user, from: from)
        end

        it 'is valid with valid attributes' do
          expect(build_schedule(6.weeks.from_now.beginning_of_day)).to be_valid
        end

        it 'is not nil' do
          expect(build_schedule(nil)).to_not be_valid
        end

        it 'is a minimum of six weeks in the future' do
          expect(build_schedule(1.day.ago.beginning_of_day)).to_not be_valid
          expect(build_schedule(5.weeks.from_now.beginning_of_day)).to_not be_valid
        end
      end
    end
  end
end
