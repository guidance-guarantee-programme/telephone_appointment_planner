require 'rails_helper'

RSpec.describe BookableSlot, type: :model do
  def make_time(hour, minute)
    5
      .business_days
      .from_now
      .change(hour: hour, min: minute)
  end

  def result
    BookableSlot.with_guider_count(
      5.business_days.ago,
      10.business_day.from_now
    )
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
