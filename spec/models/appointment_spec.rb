require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'validations' do
    required = [
      :user,
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

  describe '#assign_random_guider' do
    context 'with a guider who has a slot available' do
      let!(:guider_with_slot) do
        guider_with_slot = create(:guider)
        guider_with_slot.schedules.build(
          start_at: Time.zone.now.beginning_of_day,
          slots: [
            build(:slot, day: Date::DAYNAMES[Time.zone.now.wday], start_at: '09:00', end_at: '10:30')
          ]
        )
        guider_with_slot.save!
        guider_with_slot
      end

      it 'assigns a guider' do
        subject.start_at = Time.zone.now.change(hour: 9, min: 0)
        subject.end_at = Time.zone.now.change(hour: 10, min: 30)
        subject.assign_random_guider
        expect(subject.user).to eq guider_with_slot
      end
    end
  end
end
