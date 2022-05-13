require 'rails_helper'

RSpec.describe Api::V1::Appointment, '#create' do
  it 'defaults nudged correctly' do
    expect(described_class.new(nudged: '').nudged).to be false
  end

  skip 'does not allow duplicate bookings' do
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

  it 'defaults `lloyds_signposted` to false when not provided' do
    appointment = described_class.new({})

    expect(appointment.model.lloyds_signposted).to be(false)
  end

  it 'defaults `nudged` to false when not provided' do
    appointment = described_class.new({})

    expect(appointment.model.nudged).to be(false)
  end
end
