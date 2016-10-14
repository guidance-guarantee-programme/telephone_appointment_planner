require 'rails_helper'

RSpec.describe BookableSlot, type: :model do
  def make_time(hour, minute)
    BusinessDays
      .from_now(5)
      .change(hour: hour, min: minute)
  end

  def result
    BookableSlot.with_guider_count(
      BusinessDays.before_now(5),
      BusinessDays.from_now(10)
    )
  end

  describe '#next_valid_start_date' do
    {
      'Monday'    => 'Thursday',
      'Tuesday'   => 'Friday',
      'Wednesday' => 'Monday',
      'Thursday'  => 'Tuesday',
      'Friday'    => 'Wednesday',
      'Saturday'  => 'Wednesday',
      'Sunday'    => 'Wednesday'
    }.each do |day, expected_day|
      context "Day is #{day}" do
        it "next valid start date is #{expected_day}" do
          now = Chronic.parse("next #{day}").in_time_zone
          travel_to(now) do
            actual = BookableSlot.next_valid_start_date.strftime('%A')
            expect(actual).to eq expected_day
          end
        end
      end
    end
  end

  describe '#with_guider_count' do
    context 'three guiders with bookable slots' do
      before do
        1.upto(3) do
          guider = create(:guider)

          create(
            :bookable_slot,
            guider: guider,
            start_at: make_time(10, 30),
            end_at: make_time(11, 30)
          )
        end
      end

      it 'returns bookable slots' do
        expect(result).to eq(
          [
            guiders: 3,
            start: make_time(10, 30),
            end: make_time(11, 30)
          ]
        )
      end

      it 'excludes bookables slots that start too soon' do
        create(
          :bookable_slot,
          guider: create(:guider),
          start_at: BusinessDays.from_now(1).change(hour: 10, min: 30),
          end_at: BusinessDays.from_now(1).change(hour: 11, min: 30)
        )
        expect(result).to eq(
          [
            guiders: 3,
            start: make_time(10, 30),
            end: make_time(11, 30)
          ]
        )
      end

      context 'one guider has a bookable slot obscured by an appointment' do
        it 'excludes the slot' do
          create(
            :appointment,
            guider: User.guiders.first,
            start_at: make_time(10, 30),
            end_at: make_time(11, 30)
          )

          expect(result).to eq(
            [
              guiders: 2,
              start: make_time(10, 30),
              end: make_time(11, 30)
            ]
          )
        end
      end
    end
  end
end
