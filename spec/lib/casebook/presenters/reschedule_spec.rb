require 'rails_helper'

RSpec.describe Casebook::Presenters::Reschedule, '#to_h' do
  let(:appointment) { build_stubbed(:appointment, :casebook_guider, :pension_wise_rescheduled) }

  subject { described_class.new(appointment).to_h[:data][:attributes] }

  it 'is correctly presented' do
    expect(subject).to include(
      first_name: appointment.first_name,
      last_name: appointment.last_name,
      date_of_birth: '1945-01-01',
      mobile_phone: '07715 930 444',
      email: 'someone@example.com',
      notes: "Pension Wise online booking ##{appointment.id}.",
      user_id: appointment.guider.casebook_guider_id,
      channel: 'telephone',
      location_id: 26_089,
      reschedule_status: 'office_rescheduled'
    )
  end
end
