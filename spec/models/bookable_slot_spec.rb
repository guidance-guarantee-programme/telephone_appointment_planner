require 'rails_helper'

RSpec.describe BookableSlot, type: :model do
  def make_time(hour, minute)
    BusinessDays
      .from_now(5)
      .change(hour: hour, min: minute)
  end

  def result
    BookableSlot.with_guider_count(
      user,
      BusinessDays.before_now(5),
      BusinessDays.from_now(10)
    )
  end

  let(:user) do
    build_stubbed(:guider)
  end

  describe '#next_valid_start_date' do
    {
      'Monday'    => 'Wednesday',
      'Tuesday'   => 'Thursday',
      'Wednesday' => 'Friday',
      'Thursday'  => 'Monday',
      'Friday'    => 'Tuesday',
      'Saturday'  => 'Tuesday',
      'Sunday'    => 'Tuesday'
    }.each do |day, expected_day|
      context "Day is #{day}" do
        it "next valid start date is #{expected_day}" do
          now = Chronic.parse("next #{day}").in_time_zone
          travel_to(now) do
            actual = BookableSlot.next_valid_start_date(user).strftime('%A')
            expect(actual).to eq expected_day
          end
        end
      end
    end

    context 'user is a resource manager' do
      let(:user) do
        build_stubbed(:resource_manager)
      end

      it 'is now' do
        now = Chronic.parse('next Monday').in_time_zone
        travel_to(now) do
          actual = BookableSlot.next_valid_start_date(user)
          expect(actual).to eq now
        end
      end
    end
  end

  describe '#without_appointments' do
    let(:guider) do
      create(:guider)
    end

    let!(:slot) do
      create(
        :bookable_slot,
        guider: guider,
        start_at: make_time(10, 30),
        end_at: make_time(11, 30)
      )
    end

    subject do
      BookableSlot.without_appointments
    end

    it 'excludes slots with appointments' do
      create(
        :appointment,
        guider: guider,
        start_at: make_time(10, 30),
        end_at: make_time(11, 30),
        status: :pending
      )
      expect(subject).to_not include slot
    end

    it 'includes slots with cancelled appointments' do
      create(
        :appointment,
        guider: guider,
        start_at: make_time(10, 30),
        end_at: make_time(11, 30),
        status: :cancelled_by_customer
      )
      expect(subject).to include slot
    end
  end

  describe '#without_holidays' do
    let(:guider) do
      create(:guider)
    end

    let!(:slot) do
      create(
        :bookable_slot,
        guider: guider,
        start_at: make_time(10, 30),
        end_at: make_time(11, 30)
      )
    end

    subject do
      BookableSlot.without_holidays
    end

    context 'holiday starts at same time as bookable slot' do
      # This issue was found in production:
      # bookable slot = 8:30 to 9:40
      # holiday       = 8:30 to 9:45

      before do
        create(
          :holiday,
          user: guider,
          start_at: make_time(10, 30),
          end_at: make_time(11, 45)
        )
      end

      it 'excludes the slot' do
        expect(subject).to_not include slot
      end
    end

    context 'holiday ends at same time as bookable slot' do
      before do
        create(
          :holiday,
          user: guider,
          start_at: make_time(9, 0),
          end_at: make_time(11, 30)
        )
      end

      it 'excludes the slot' do
        expect(subject).to_not include slot
      end
    end

    it 'does not exclude everything' do
      expect(subject).to include slot
    end

    it 'excludes slots with bank holidays' do
      create(
        :bank_holiday,
        start_at: make_time(6, 30),
        end_at: make_time(18, 30)
      )

      expect(subject).to_not include slot
    end

    it 'excludes slots with user holidays' do
      create(
        :holiday,
        user: guider,
        start_at: make_time(5, 30),
        end_at: make_time(20, 30)
      )

      expect(subject).to_not include slot
    end

    it 'excludes slots with holidays that start inside them' do
      create(
        :holiday,
        user: guider,
        start_at: make_time(11, 0),
        end_at: make_time(12, 30)
      )

      expect(subject).to_not include slot
    end

    it 'excludes slots with holidays that end inside them' do
      create(
        :holiday,
        user: guider,
        start_at: make_time(8, 0),
        end_at: make_time(10, 31)
      )

      expect(subject).to_not include slot
    end

    it 'does not exclude slots that start directly after a holiday' do
      create(
        :holiday,
        user: guider,
        start_at: make_time(11, 30),
        end_at: make_time(12, 30)
      )

      expect(subject).to include slot
    end

    it 'does not exclude slots that end directly before a holiday' do
      create(
        :holiday,
        user: guider,
        start_at: make_time(9, 30),
        end_at: make_time(10, 30)
      )

      expect(subject).to include slot
    end
  end

  describe '#with_guider_count' do
    context 'three guiders with bookable slots' do
      let(:guiders) do
        create_list(:guider, 3)
      end

      before do
        guiders.each do |guider|
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
            end: make_time(11, 30),
            selected: false
          ]
        )
      end

      it 'excludes bookables slots that start within two business days' do
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
            end: make_time(11, 30),
            selected: false
          ]
        )
      end

      context 'user is a resource manager' do
        let(:user) do
          build_stubbed(:resource_manager)
        end

        it 'includes bookable slots that start after now' do
          start_at = BusinessDays.from_now(1).change(hour: 12, min: 30)
          end_at = BusinessDays.from_now(1).change(hour: 14, min: 30)
          create(
            :bookable_slot,
            guider: create(:guider),
            start_at: start_at,
            end_at: end_at
          )

          expect(result.count).to eq 2
          expect(result).to include(
            guiders: 3,
            start: make_time(10, 30),
            end: make_time(11, 30),
            selected: false
          )
          expect(result).to include(
            guiders: 1,
            start: start_at,
            end: end_at,
            selected: false
          )
        end
      end

      context 'one guider has a bookable slot obscured by a non cancelled appointment' do
        it 'excludes the slot' do
          create(
            :appointment,
            guider: User.guiders.first,
            start_at: make_time(10, 30),
            end_at: make_time(11, 30),
            status: :pending
          )

          expect(result).to eq(
            [
              guiders: 2,
              start: make_time(10, 30),
              end: make_time(11, 30),
              selected: false
            ]
          )
        end
      end

      context 'two guiders have bookable slots not obscured by cancelled appointments' do
        it 'does not exclude the slot' do
          create(
            :appointment,
            guider: User.guiders.first,
            start_at: make_time(10, 30),
            end_at: make_time(11, 30),
            status: :cancelled_by_customer
          )

          create(
            :appointment,
            guider: User.guiders.last,
            start_at: make_time(10, 30),
            end_at: make_time(11, 30),
            status: :cancelled_by_pension_wise
          )

          expect(result).to eq(
            [
              guiders: 3,
              start: make_time(10, 30),
              end: make_time(11, 30),
              selected: false
            ]
          )
        end
      end

      context 'there is a holiday obscuring a bookable slot' do
        it 'excludes the slots' do
          create(
            :bank_holiday,
            start_at: make_time(6, 30),
            end_at: make_time(18, 30)
          )

          expect(result).to eq([])
        end
      end

      context 'there is a holiday for a single user that doesn\'t obscure any bookable slots' do
        it 'does not exclude the slots' do
          create(
            :holiday,
            user: guiders.first,
            start_at: make_time(19, 30),
            end_at: make_time(20, 30)
          )

          expect(result).to eq [
            guiders: 3,
            start: make_time(10, 30),
            end: make_time(11, 30),
            selected: false
          ]
        end
      end

      context 'there is a holiday for a single user' do
        it 'excludes the slot' do
          guider = guiders.first
          create(
            :holiday,
            user: guider,
            start_at: make_time(6, 30),
            end_at: make_time(18, 30)
          )

          expect(result).to eq(
            [
              guiders: 2,
              start: make_time(10, 30),
              end: make_time(11, 30),
              selected: false
            ]
          )
        end
      end
    end
  end
end
