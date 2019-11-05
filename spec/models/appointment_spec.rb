require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe '#cancel!' do
    it 'does not audit any changes' do
      appointment = create(:appointment)
      appointment.audits.destroy_all

      appointment.cancel!

      expect(appointment.reload.audits).to be_empty
    end
  end

  describe '.for_sms_cancellation' do
    context 'when two appointment exist with the same number' do
      it 'returns the appointment created first' do
        @first = create(:appointment, mobile: '07715930455', created_at: '2018-04-28 13:00')
        @last  = create(:appointment, mobile: '07715930455', created_at: '2018-04-28 14:00')

        expect(described_class.for_sms_cancellation('07715930455')).to eq(@first)
      end
    end
  end

  context 'when the status changes before saving' do
    it 'stores the associated statuses' do
      appointment = create(:appointment)

      expect(appointment.status_transitions.map(&:status)).to match_array('pending')

      appointment.update(status: 'cancelled_by_pension_wise')

      expect(appointment.status_transitions.map(&:status)).to match_array(
        %w(pending cancelled_by_pension_wise)
      )
    end

    context 'changing from a cancellation back to pending' do
      it 'is invalid when the original slot is taken' do
        @guider      = create(:guider)
        @cancelled   = create(:appointment, status: :cancelled_by_customer, guider: @guider)
        @appointment = create(:appointment, guider: @guider)

        @cancelled.status = :pending
        expect(@cancelled).to be_invalid

        @appointment.update(status: :cancelled_by_customer)
        expect(@cancelled).to be_valid
      end
    end
  end

  context 'when copying an appointment that had printed confirmation' do
    it 'ensures the copy will also be batch processed' do
      @old  = create(:appointment, batch_processed_at: Time.zone.now, status: :complete)
      @copy = Appointment.copy_or_new_by(@old.id)

      expect(@copy).not_to be_batch_processed_at
    end
  end

  describe '#canonical_sms_number' do
    context 'when a `mobile` is present' do
      it 'returns the `mobile`' do
        @appointment = Appointment.new(
          phone: '07715 930 444',
          mobile: '07715 999 123'
        )

        expect(@appointment.canonical_sms_number).to eq(@appointment.mobile)
      end
    end

    context 'when a `phone` is present' do
      it 'returns the `phone`' do
        @appointment = Appointment.new(
          phone: '07715 930 444',
          mobile: ''
        )

        expect(@appointment.canonical_sms_number).to eq(@appointment.phone)
      end
    end
  end

  describe '#type_of_appointment' do
    context 'without a date of birth' do
      it 'returns an empty string' do
        appointment = build_stubbed(
          :appointment,
          date_of_birth: '',
          type_of_appointment: ''
        )

        expect(appointment.type_of_appointment).to be_empty
      end
    end

    context 'when specified' do
      it 'returns the underlying attribute' do
        expect(create(:appointment).type_of_appointment).to eq('50-54')
      end
    end

    context 'when unspecified' do
      it 'is inferred from the date of birth' do
        expect(
          build_stubbed(:appointment, type_of_appointment: '').type_of_appointment
        ).to eq('standard')
      end
    end
  end

  describe '#age_at_appointment' do
    context 'without a date of birth' do
      it 'is 0' do
        expect(build_stubbed(:appointment, date_of_birth: '').age_at_appointment).to eq(0)
      end
    end

    context 'when a date of birth is present' do
      it 'returns the age at the time of the appointment' do
        appointment = build_stubbed(
          :appointment,
          date_of_birth: '1980-02-02',
          start_at: Time.zone.parse('2017-01-20 13:00')
        )
        expect(appointment.age_at_appointment).to eq(36)

        appointment.start_at = Time.zone.parse('2017-02-02 13:00')
        expect(appointment.age_at_appointment).to eq(37)
      end
    end
  end

  describe '#timezone' do
    it 'returns "GMT" when the appointment is in winter time' do
      appointment = described_class.new(start_at: Time.zone.parse('1 January 2017 12:00'))
      expect(appointment.timezone).to eq 'GMT'
    end

    it 'returns "BST" when the appointment is in summer time' do
      appointment = described_class.new(start_at: Time.zone.parse('1 June 2017 12:00'))
      expect(appointment.timezone).to eq 'BST'
    end
  end

  describe 'Phantom audits bug regression' do
    it 'defaults `mobile` and `notes` to empty strings' do
      expect(described_class.new).to have_attributes(
        mobile: '',
        notes: ''
      )
    end
  end

  describe 'Grace period bug regression' do
    it 'does not permit bookings inside the grace period' do
      travel_to '2017-03-26 11:05 UTC' do
        # force new_record? to evaluate truthily
        appointment = Appointment.new(
          attributes_for(:appointment, agent: build_stubbed(:agent), start_at: Time.zone.parse('2017-03-27 11:20 UTC'))
        )

        expect(appointment).to be_invalid
      end
    end
  end

  describe 'formatting' do
    it 'title-cases first and last name' do
      appointment = build(:appointment, first_name: 'bob', last_name: 'carolgees')
      appointment.validate

      expect(appointment).to have_attributes(
        first_name: 'Bob',
        last_name: 'Carolgees'
      )
    end
  end

  describe 'validations' do
    let(:subject) do
      build_stubbed(:appointment)
    end

    context 'when specifying accessibility requirements' do
      it 'requires additional notes to be specified' do
        subject.accessibility_requirements = true
        subject.notes = ''
        expect(subject).to be_invalid

        subject.notes = 'They require some assistance'
        expect(subject).to be_valid

        # no notes required before cutoff date of 2019-09-25
        subject.created_at = '2019-01-01'.to_date
        subject.notes = ''
        expect(subject).to be_valid
      end
    end

    describe 'rescheduling across organisations' do
      it 'is not possible' do
        @cas_guider  = create(:guider, :cas)
        @appointment = create(:appointment)

        @appointment.guider = @cas_guider

        expect(@appointment).to be_invalid
      end
    end

    it 'defaults #status to `pending`' do
      expect(described_class.new).to be_pending
    end

    it 'is valid with valid parameters' do
      expect(subject).to be_valid
    end

    context 'when rebooked' do
      it 'does not validate WDYH' do
        subject.id = nil
        subject.rebooked_from_id = 1
        subject.where_you_heard  = nil

        expect(subject).to be_valid
      end
    end

    required = [
      :start_at,
      :end_at,
      :first_name,
      :last_name,
      :phone,
      :memorable_word,
      :guider,
      :agent,
      :date_of_birth,
      :dc_pot_confirmed
    ]
    required.each do |field|
      it "validate presence of #{field}" do
        subject.public_send("#{field}=", nil)
        subject.validate
        expect(subject.errors[field]).to_not be_empty
      end
    end

    it 'is valid when dc_pot_confirmed is true' do
      subject.dc_pot_confirmed = true
      subject.validate
      expect(subject.errors[:dc_pot_confirmed]).to be_empty
    end

    it 'is valid when dc_pot_confirmed is false' do
      subject.dc_pot_confirmed = false
      subject.validate
      expect(subject.errors[:dc_pot_confirmed]).to be_empty
    end

    context 'when created by an API agent' do
      it 'requires a reasonably valid email' do
        appointment = build(
          :appointment,
          email: 'a.com',
          agent: build(:pension_wise_api_user)
        )

        expect(appointment).to_not be_valid
      end
    end

    context 'when created by a non-API agent' do
      before { subject.id = nil } # not persisted yet

      context 'when no postal address is supplied' do
        it '#address? is false' do
          expect(subject).not_to be_address
        end

        it 'requires an email address' do
          subject.email = ''

          expect(subject).to be_invalid
        end
      end

      context 'when a postal address is provided' do
        before do
          subject.address_line_one = '10 Some Street'
          subject.town = 'Some Town'
          subject.postcode = 'RM1 1AA'
        end

        it '#address? is true' do
          expect(subject).to be_address
        end

        it 'does not require an email' do
          subject.email = ''

          expect(subject).to be_valid
        end

        it 'does not permit the presence of an email' do
          subject.email = 'ben@example.com'

          expect(subject).to be_invalid
          expect(subject.errors[:email]).not_to be_empty
        end
      end
    end

    context 'when not persisted' do
      before { allow(subject).to receive(:new_record?).and_return(true) }

      it 'cannot be booked at short notice' do
        subject.agent = build_stubbed(:agent)
        subject.start_at = 1.hour.from_now
        subject.validate
        expect(subject.errors[:start_at]).to_not be_empty
      end

      context 'agent is a resource manager' do
        it 'can be booked within two working days' do
          subject.agent = build_stubbed(:resource_manager)
          subject.start_at = BusinessDays.from_now(1)
          subject.validate
          expect(subject.errors[:start_at]).to be_empty
        end
      end
    end

    it 'cannot be booked further ahead than forty five working days' do
      subject.start_at = BusinessDays.from_now(46)
      subject.validate
      expect(subject.errors[:start_at]).to_not be_empty
    end

    context 'with an invalid date of birth' do
      it 'is invalid' do
        subject.date_of_birth = { 1 => 2016, 2 => 2, 3 => 31 }
        subject.validate
        expect(subject.errors[:date_of_birth]).to eq ['must be valid']
      end
    end

    context 'when the date of birth is prior to 1900' do
      it 'is invalid' do
        subject.date_of_birth = '1899-12-31'

        expect(subject).to_not be_valid
      end
    end
  end

  describe '#allocate' do
    let(:appointment_start_time) do
      BusinessDays.from_now(5).change(hour: 9, min: 0, second: 0)
    end

    let(:appointment_end_time) do
      BusinessDays.from_now(5).change(hour: 10, min: 30, second: 0)
    end

    context 'when booking as a TPAS agent' do
      it 'excludes TP guiders' do
        tpas_resource_manager = create(:resource_manager, :tpas)
        tp_resource_manager   = create(:resource_manager, :tp)

        tp_guider   = guider_with_slot(:tp)
        tpas_guider = guider_with_slot(:tpas)

        subject.start_at = appointment_start_time
        subject.end_at   = appointment_end_time

        subject.allocate(agent: tpas_resource_manager)
        expect(subject.guider).to eq(tpas_guider)

        subject.allocate(agent: tp_resource_manager)
        expect(subject.guider).to eq(tp_guider)
      end

      def guider_with_slot(provider) # rubocop:disable MethodLength
        guider = create(:guider, provider)
        guider.schedules.build(
          start_at: appointment_start_time.beginning_of_day,
          slots: [
            build(
              :slot,
              day_of_week: appointment_start_time.wday,
              start_hour: 9,
              start_minute: 0,
              end_hour: 10,
              end_minute: 30
            )
          ]
        )
        guider.save!

        create(
          :bookable_slot,
          guider: guider,
          start_at: appointment_start_time,
          end_at: appointment_end_time
        )

        guider
      end
    end

    context 'with a guider who has a slot at the appointment time' do
      let!(:guider_with_slot) do
        guider_with_slot = create(:guider)
        guider_with_slot.schedules.build(
          start_at: appointment_start_time.beginning_of_day,
          slots: [
            build(
              :slot,
              day_of_week: appointment_start_time.wday,
              start_hour: 9,
              start_minute: 0,
              end_hour: 10,
              end_minute: 30
            )
          ]
        )
        guider_with_slot.save!
        guider_with_slot
      end

      let!(:bookable_slot) do
        create(
          :bookable_slot,
          guider: guider_with_slot,
          start_at: appointment_start_time,
          end_at: appointment_end_time
        )
      end

      it 'assigns to a guider' do
        subject.first_name = 'Andrew'
        subject.last_name = 'Something'
        subject.phone = '32424'
        subject.memorable_word = 'lozenge'
        subject.start_at = appointment_start_time
        subject.end_at = appointment_end_time
        subject.allocate
        expect(subject.guider).to eq guider_with_slot
      end

      context 'and the guider already has an appointment at that time' do
        before do
          create(
            :appointment,
            guider: guider_with_slot,
            start_at: appointment_start_time,
            end_at: appointment_end_time
          )
        end

        it 'does not assign to a guider' do
          subject.start_at = appointment_start_time
          subject.end_at = appointment_end_time
          expect { subject.allocate }.to_not change { subject.guider }
        end
      end

      context 'and the guider already has a holiday at that time' do
        before do
          create(
            :holiday,
            user: guider_with_slot,
            start_at: appointment_start_time.beginning_of_day,
            end_at: appointment_end_time.end_of_day
          )
        end

        it 'does not assign to a guider' do
          subject.start_at = appointment_start_time
          subject.end_at = appointment_end_time
          expect { subject.allocate }.to_not change { subject.guider }
        end
      end

      context 'and there is a bank holiday at that time' do
        before do
          create(
            :bank_holiday,
            start_at: appointment_start_time.beginning_of_day,
            end_at: appointment_end_time.end_of_day
          )
        end

        it 'does not assign to a guider' do
          subject.start_at = appointment_start_time
          subject.end_at = appointment_end_time
          expect { subject.allocate }.to_not change { subject.guider }
        end
      end
    end
  end

  describe '#imported?' do
    it 'is true for appointments matching the imported (fake) date of birth' do
      appointment = build_stubbed(
        :appointment,
        date_of_birth: Appointment::FAKE_DATE_OF_BIRTH
      )

      expect(appointment).to be_imported
    end

    it 'is false otherwise' do
      expect(build_stubbed(:appointment)).to_not be_imported
    end
  end

  describe '#name' do
    subject { build_stubbed(:appointment, first_name: 'Joe', last_name: 'Bloggs') }

    it 'returns the combination of first name and last name' do
      expect(subject.name).to eq 'Joe Bloggs'
    end
  end

  describe '#can_be_rescheduled_by?' do
    let(:result) do
      appointment.can_be_rescheduled_by?(user)
    end

    context 'appointment is more than two days in the future' do
      let(:appointment) do
        build_stubbed(:appointment, start_at: BusinessDays.from_now(3))
      end

      context 'user is a guider' do
        let(:user) do
          build_stubbed(:guider)
        end

        it 'is true' do
          expect(result).to be true
        end
      end

      context 'user is a resource manager' do
        let(:user) do
          build_stubbed(:resource_manager)
        end

        it 'is true' do
          expect(result).to be true
        end
      end
    end

    context 'appointment is less than two days in the future' do
      let(:appointment) do
        build_stubbed(:appointment, start_at: BusinessDays.from_now(1))
      end

      context 'user is a guider' do
        let(:user) do
          build_stubbed(:guider)
        end

        it 'is false' do
          expect(result).to be false
        end
      end

      context 'user is a resource manager' do
        let(:user) do
          build_stubbed(:resource_manager)
        end

        it 'is true' do
          expect(result).to be true
        end
      end
    end
  end

  describe '#can_create_summary?' do
    let(:result) { Appointment.new(status: status).can_create_summary? }

    %i(complete ineligible_age ineligible_pension_type).each do |status|
      context "when status is #{status}" do
        let(:status) { status }

        it 'is true' do
          expect(result).to be true
        end
      end
    end

    %i(pending no_show incomplete cancelled_by_customer cancelled_by_pension_wise).each do |status|
      context "when status is #{status}" do
        let(:status) { status }

        it 'is false' do
          expect(result).to be false
        end
      end
    end
  end

  describe '.needing_reminder' do
    context 'on the same day as booking' do
      it 'does not return the appointment' do
        @date = BusinessDays.from_now(2)
        appointment = create(:appointment, created_at: @date, start_at: @date)

        travel_to(appointment.start_at - 5.hours) do
          expect(Appointment.needing_reminder).not_to include(appointment)
        end
      end
    end

    context 'less than 3 hours before the appointment' do
      it 'does not return the appointment' do
        appointment = create(:appointment, start_at: BusinessDays.from_now(20))

        travel_to(appointment.start_at - 2.hours) do
          expect(Appointment.needing_reminder).not_to include(appointment)
        end
      end
    end

    context 'more than 48 hours before the appointment' do
      it 'does not return the appointment' do
        appointment = create(:appointment, start_at: BusinessDays.from_now(20))

        expect(Appointment.needing_reminder).to_not include(appointment)
      end
    end

    context 'less than 48 hours before the appointment' do
      it 'returns the appointment' do
        appointment = create(:appointment, start_at: BusinessDays.from_now(20))

        travel_to(appointment.start_at - 47.hours) do
          expect(Appointment.needing_reminder).to include(appointment)
        end
      end

      context 'and the appointment has no email address' do
        it 'does not return the appointment' do
          appointment = create(:appointment, :with_address, email: '', start_at: BusinessDays.from_now(20))

          travel_to(appointment.start_at - 47.hours) do
            expect(Appointment.needing_reminder).to_not include(appointment)
          end
        end
      end

      context 'and the appointment is not pending' do
        it 'does not return the appointment' do
          appointment = create(:appointment, :api, status: 'cancelled_by_customer', start_at: BusinessDays.from_now(20))

          travel_to(appointment.start_at - 47.hours) do
            expect(Appointment.needing_reminder).to_not include(appointment)
          end
        end
      end
    end
  end

  describe '.needing_sms_reminder' do
    it 'includes the correct appointments at given periods' do
      # excluded before
      create(:appointment, start_at: 20.days.from_now)
      # this is included
      found = create(:appointment, start_at: 21.days.from_now.change(hour: 13, min: 30))
      # excluded after
      create(:appointment, start_at: 22.days.from_now)

      # at roughly two days prior
      travel_to(found.start_at - 47.hours) do
        expect(Appointment.needing_sms_reminder).to contain_exactly(found)
      end

      # at roughly seven days prior
      travel_to(found.start_at - (7 * 24 - 1).hours) do
        expect(Appointment.needing_sms_reminder).to contain_exactly(found)
      end
    end
  end
end
