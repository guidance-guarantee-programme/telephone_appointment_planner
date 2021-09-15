require 'rails_helper'

RSpec.describe DueDiligenceReferenceNumber, '#call' do
  it 'generates a number in the correct format 123456ddmmyyyy' do
    @appointment = double(Appointment, start_at: Time.zone.parse('2021-09-14 13:00'))

    reference = described_class.new(@appointment).call

    expect(reference).to match(/\A\d{6}14092021\z/)
  end
end
