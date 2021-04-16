require 'rails_helper'

RSpec.describe Api::V1::Appointment, '#create' do
  it 'does not allow duplicate bookings' do
    skip 'This seems to be time-dependent and needs addressing separately'

    @slot = create(:bookable_slot, start_at: 2.days.from_now.middle_of_day)

    @attributes = {
      start_at: @slot.start_at,
      first_name: 'Daisy',
      last_name: 'George',
      email: 'daisy@example.com',
      phone: '0208 252 4768',
      memorable_word: 'spaceships',
      date_of_birth: '1970-01-01',
      dc_pot_confirmed: true,
      where_you_heard: 1,
      gdpr_consent: 'yes',
      accessibility_requirements: false,
      notes: '',
      agent: create(:agent),
      smarter_signposted: false,
      lloyds_signposted: false
    }

    @first  = described_class.new(@attributes)
    @second = described_class.new(@attributes)

    expect do
      first  = Thread.new { @first.create }
      second = Thread.new { @second.create }

      first.join
      second.join
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
