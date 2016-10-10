require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'validations' do
    it 'is valid with valid parameters' do
      appointment = create(:appointment)
      expect(appointment).to be_valid
    end

    required = [
      :start_at,
      :end_at,
      :first_name,
      :last_name,
      :phone,
      :memorable_word
    ]
    required.each do |r|
      it "validate presence of #{r}" do
        subject.validate
        expect(subject.errors[r]).to_not be_empty
      end
    end
  end

  describe '#assign_to_guider' do
    let(:appointment_start_time) do
      Time.zone.now.change(hour: 9, min: 0, second: 0)
    end

    let(:appointment_end_time) do
      Time.zone.now.change(hour: 10, min: 30, second: 0)
    end

    context 'with a guider who has a slot at the appointment time' do
      let!(:guider_with_slot) do
        guider_with_slot = create(:guider)
        guider_with_slot.schedules.build(
          start_at: Time.zone.now.beginning_of_day,
          slots: [
            build(
              :slot,
              day_of_week: Time.zone.now.wday,
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

      let!(:usable_slot) do
        create(
          :usable_slot,
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
    end
  end
end
