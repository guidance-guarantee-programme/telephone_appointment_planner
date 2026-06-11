require 'rails_helper'

RSpec.describe Genesys::Reschedule, '#call' do
  let(:api) { double(Api) }
  let(:appointment) { double(Appointment, process_genesys_rescheduling!: true) }

  before do
    allow(api).to receive(:push).with(appointment, rescheduling: true).and_return('deadbeef')
  end

  subject { described_class.new(appointment, api:) }

  it 'pushes and sets the genesys rescheduling operation ID' do
    subject.call

    expect(appointment).to have_received(:process_genesys_rescheduling!).with('deadbeef')
  end
end
