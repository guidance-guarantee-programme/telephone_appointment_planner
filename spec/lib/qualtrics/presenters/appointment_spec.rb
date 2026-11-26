require 'rails_helper'

RSpec.describe Qualtrics::Presenters::Appointment, '#to_h' do # rubocop:disable Metrics/BlockLength
  let(:appointment) do
    build_stubbed(
      :appointment,
      id: 999,
      first_name: 'Bob',
      last_name: 'Smith',
      email: 'bob@example.com',
      mobile: '07715930459'
    )
  end

  subject { described_class.new(appointment) }

  it 'maps the standard attributes' do
    expect(subject.to_h).to include(
      reference: 999,
      first_name: 'Bob',
      last_name: 'Smith',
      email: 'bob@example.com'
    )
  end

  it 'maps the mobile number' do
    expect(subject.to_h).to include(mobile: '07715930459')

    appointment.mobile = ''
    appointment.phone  = '02082524729'
    expect(subject.to_h).to include(mobile: '')
  end

  it 'maps the type' do
    expect(subject.to_h).to include(type: 'pensionwise-phone')

    appointment.schedule_type = 'due_diligence'
    expect(subject.to_h).to include(type: 'psg-phone')
  end
end
