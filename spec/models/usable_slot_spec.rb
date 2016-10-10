require 'rails_helper'

RSpec.describe UsableSlot, type: :model do
  describe '#with_guider_count' do
    context 'three guiders with usable slots' do
      before do
        1.upto(3) do
          guider = create(:guider)

          create(
            :usable_slot,
            guider: guider,
            start_at: DateTime.new(2022, 12, 9, 10, 30, 0).in_time_zone,
            end_at: DateTime.new(2022, 12, 9, 11, 30, 0).in_time_zone
          )
        end
      end

      it 'returns usable slots' do
        result = UsableSlot.with_guider_count(
          Date.new(2022, 12, 5),
          Date.new(2022, 12, 20)
        )

        expect(result).to eq(
          [
            guiders: 3,
            start: DateTime.new(2022, 12, 9, 10, 30, 0).in_time_zone,
            end: DateTime.new(2022, 12, 9, 11, 30, 0).in_time_zone
          ]
        )
      end

      context 'one guider has a usable_slot obscured by an appointment' do
        it 'excludes the slot' do
          create(
            :appointment,
            guider: User.guiders.first,
            start_at: DateTime.new(2022, 12, 9, 10, 30, 0).in_time_zone,
            end_at: DateTime.new(2022, 12, 9, 11, 30, 0).in_time_zone
          )

          result = UsableSlot.with_guider_count(
            Date.new(2022, 12, 5),
            Date.new(2022, 12, 20)
          )

          expect(result).to eq(
            [
              guiders: 2,
              start: DateTime.new(2022, 12, 9, 10, 30, 0).in_time_zone,
              end: DateTime.new(2022, 12, 9, 11, 30, 0).in_time_zone
            ]
          )
        end
      end
    end
  end
end
