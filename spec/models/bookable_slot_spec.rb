require 'rails_helper'

RSpec.describe BookableSlot, type: :model do
  def make_time(hour, minute)
    BusinessDays
      .from_now(5)
      .change(hour: hour, min: minute)
  end

  def result(current_user = user)
    BookableSlot.with_guider_count(
      current_user,
      BusinessDays.before_now(5),
      BusinessDays.from_now(10)
    )
  end

  let(:user) do
    build_stubbed(:guider, :tp)
  end

  describe '#schedule_type' do
    it 'defaults to pension_wise' do
      bookable_slot = build(:bookable_slot)

      expect(bookable_slot.schedule_type).to eq(User::PENSION_WISE_SCHEDULE_TYPE)
    end
  end

  describe '.create_from_slot!' do
    it 'infers the schedule type from the given guider' do
      slot   = build(:slot)
      guider = build(:guider, :tpas, :due_diligence)

      result = BookableSlot.create_from_slot!(guider, Time.zone.now, slot)

      expect(result.schedule_type).to eq(User::DUE_DILIGENCE_SCHEDULE_TYPE)
    end
  end

  describe '.find_available_slot' do
    it 'returns a slot for the correct organisation' do
      start_at = Time.zone.parse('2021-05-26 13:00')

      %i(tp cas ni wallsend lancs_west).each do |provider|
        create(:bookable_slot, provider, start_at: start_at)
      end

      @expected = create(:bookable_slot, :derbyshire_districts, start_at: start_at)

      @allocated = BookableSlot.find_available_slot(start_at, @expected.guider)

      expect(@allocated).to eq(@expected)
    end
  end

  describe '#next_valid_start_date' do
    context 'for the due diligence schedule type' do
      it 'is effectively 5 days' do
        travel_to '2021-10-25 10:00' do
          actual = BookableSlot.next_valid_start_date(user, User::DUE_DILIGENCE_SCHEDULE_TYPE)
          expect(actual).to eq(Time.zone.parse('2021-11-01 21:00'))
        end
      end
    end

    context 'user is a guider / agent' do
      context 'outside of a bank holiday period' do
        before { travel_to('2017-04-06 12:00') }
        after { travel_back }

        {
          'Monday'    => 'Tuesday',
          'Tuesday'   => 'Wednesday',
          'Wednesday' => 'Thursday',
          'Thursday'  => 'Friday',
          'Friday'    => 'Monday',
          'Saturday'  => 'Monday',
          'Sunday'    => 'Monday'
        }.each do |day, expected_day|
          context "Day is #{day}" do
            it "next valid start date is #{expected_day}" do
              now = Chronic.parse("last week #{day}").in_time_zone
              travel_to(now)

              actual = BookableSlot.next_valid_start_date(user).strftime('%A')
              expect(actual).to eq expected_day
            end
          end
        end
      end

      context 'when approaching a holiday period' do
        subject { BookableSlot.next_valid_start_date(user) }

        it 'takes account of holidays' do
          travel_to '2021-12-25 12:00' do
            expect(subject.to_date).to eq('2021-12-29'.to_date)
          end
        end
      end

      it 'respects timezones eg DST/BST' do
        # DST
        travel_to '2020-01-01 13:00' do
          expect(BookableSlot.next_valid_start_date(user)).to eq('2020-01-02 21:00 UTC'.to_time.in_time_zone('London'))
        end

        # BST
        travel_to '2020-04-14 13:00' do
          expect(BookableSlot.next_valid_start_date(user)).to eq('2020-04-15 21:00 UTC'.to_time.in_time_zone('London'))
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

    it 'excludes slots with both a cancelled and a pending appointment' do
      create(
        :appointment,
        guider: guider,
        start_at: make_time(10, 30),
        end_at: make_time(11, 30),
        status: :cancelled_by_customer_sms
      )
      create(
        :appointment,
        guider: guider,
        start_at: make_time(10, 30),
        end_at: make_time(11, 30),
        status: :pending
      )
      expect(subject).to_not include slot
    end

    it 'excludes slots with appointments that start inside them' do
      create(
        :appointment,
        guider: guider,
        start_at: make_time(10, 45),
        end_at: make_time(12, 30),
        status: :pending
      )
      expect(subject).to_not include slot
    end

    it 'includes slots that overlap with appointments from different schedules' do
      create(
        :appointment,
        :due_diligence,
        guider: guider,
        start_at: make_time(10, 45),
        end_at: make_time(12, 30),
        status: :pending
      )
      expect(subject).to include slot
    end

    it 'excludes slots with appointments that end inside them' do
      create(
        :appointment,
        guider: guider,
        start_at: make_time(9, 45),
        end_at: make_time(10, 35),
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
        status: :cancelled_by_customer_sms
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

    context 'excludes slots that have the same start and end as a holiday' do
      before do
        create(
          :holiday,
          user: guider,
          start_at: make_time(10, 30),
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

    context 'excludes slots with holidays with the same start' do
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

    it 'excludes slots with holidays that start inside them' do
      create(
        :holiday,
        user: guider,
        start_at: make_time(11, 0),
        end_at: make_time(12, 30)
      )

      expect(subject).to_not include slot
    end

    context 'excludes slots with holidays with the same end' do
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
    context 'when a TPAS agent' do
      it 'excludes external org slots inside the grace period start' do
        [
          @tpas_guider = create(:guider, :tpas),
          @cas_guider  = create(:guider, :cas)
        ].each do |guider|
          create(
            :bookable_slot,
            guider: guider,
            start_at: make_time(10, 30),
            end_at: make_time(11, 30)
          )
        end

        travel_to '2022-09-08 07:00' do
          expect(result(@cas_guider)).to be_empty

          expect(result(@tpas_guider).first).to include(guiders: 1)
        end
      end
    end

    describe 'requesting with differing providers' do
      it 'sees the correct slots based on organisational membership' do
        [
          @guider_tpas = create(:guider, :tpas),
          @guider_tp   = create(:agent_and_guider, :tp),
          @guiders_cas = create_list(:guider, 2, :cas)
        ].flatten.each do |guider|
          create(
            :bookable_slot,
            guider: guider,
            start_at: make_time(10, 30),
            end_at: make_time(11, 30)
          )
        end

        # TP can see all slots irrespectively
        expect(result(@guider_tp).first).to include(guiders: 4)
        # TPAS can see all slots
        expect(result(@guider_tpas).first).to include(guiders: 4)
        # CAS can see their own slots
        expect(result(@guiders_cas.first).first).to include(guiders: 2)
      end
    end

    context 'three guiders with bookable slots' do
      let(:user) { build_stubbed(:agent) }
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
            status: :cancelled_by_customer_sms
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
