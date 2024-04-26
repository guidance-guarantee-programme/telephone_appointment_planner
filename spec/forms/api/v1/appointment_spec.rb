require 'rails_helper'

RSpec.describe Api::V1::Appointment, '#create' do
  it 'defaults nudged correctly' do
    expect(described_class.new(nudged: '').nudged).to be false
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
