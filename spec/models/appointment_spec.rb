require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'validations' do
    let(:subject) do
      build_stubbed(:appointment)
    end

    it 'defaults #status to `pending`' do
      expect(described_class.new).to be_pending
    end

    it 'is valid with valid parameters' do
      expect(subject).to be_valid
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
      :date_of_birth
    ]
    required.each do |field|
      it "validate presence of #{field}" do
        subject.public_send("#{field}=", nil)
        subject.validate
        expect(subject.errors[field]).to_not be_empty
      end
    end

    context 'when not persisted' do
      before { allow(subject).to receive(:new_record?).and_return(true) }

      it 'cannot be booked within two working days' do
        subject.start_at = BusinessDays.from_now(1)
        subject.validate
        expect(subject.errors[:start_at]).to_not be_empty
      end
    end

    it 'cannot be booked further ahead than thirty working days' do
      subject.start_at = BusinessDays.from_now(40)
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
  end

  describe '#assign_to_guider' do
    let(:appointment_start_time) do
      BusinessDays.from_now(5).change(hour: 9, min: 0, second: 0)
    end

    let(:appointment_end_time) do
      BusinessDays.from_now(5).change(hour: 10, min: 30, second: 0)
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
        subject.assign_to_guider
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
          expect { subject.assign_to_guider }.to_not change { subject.guider }
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
          expect { subject.assign_to_guider }.to_not change { subject.guider }
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
          expect { subject.assign_to_guider }.to_not change { subject.guider }
        end
      end
    end
  end

  describe '#full_search' do
    before do
      from = BusinessDays.from_now(3).at_midday

      @stefan = create(:appointment, first_name: 'Stefan', last_name: 'Löfven', created_at: from + 2.seconds)
      @angela = create(:appointment, first_name: 'Angela', last_name: 'Merkel', created_at: from + 1.second)
      @adrian = create(:appointment, first_name: 'Adrian', last_name: 'Hasler', created_at: from)
    end

    def results(q, start_at, end_at)
      Appointment.full_search(q, start_at, end_at)
    end

    it 'returns all results' do
      expect(results(nil, nil, nil)).to eq [@stefan, @angela, @adrian]
    end

    it 'returns results for appointment ID' do
      results = results(@angela.id, nil, nil)
      expect(results).to eq [@angela]
    end

    it 'returns results for customer first_name' do
      results = results('adrian', nil, nil)
      expect(results).to eq [@adrian]
    end

    it 'returns results for customer last_name' do
      results = results('merkel', nil, nil)
      expect(results).to eq [@angela]
    end

    it 'returns results for prefixes' do
      results = results('Ange', nil, nil)
      expect(results).to eq [@angela]
    end

    it 'returns partial matches for words' do
      results = results('efan', nil, nil)
      expect(results).to eq [@angela]
    end

    it 'returns results for a date range' do
      date_range_start = 20.days.from_now.to_date
      date_range_end = 30.days.from_now.to_date
      start_at = date_range_start + 5.hours
      end_at = start_at + 1.hour
      appointment = create(:appointment, start_at: start_at, end_at: end_at)
      results = results(nil, date_range_start, date_range_end)
      expect(results).to eq [appointment]
    end

    it 'returns results for guider name' do
      guider = create(:guider, name: 'Kate Bush')
      @angela.guider = guider
      @angela.save!
      results = results('kate bush', nil, nil)
      expect(results).to eq [@angela]
    end
  end

  describe '#name' do
    subject { build_stubbed(:appointment, first_name: 'Joe', last_name: 'Bloggs') }

    it 'returns the combination of first name and last name' do
      expect(subject.name).to eq 'Joe Bloggs'
    end
  end
end
