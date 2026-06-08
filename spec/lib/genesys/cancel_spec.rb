require 'rails_helper'

RSpec.describe Genesys::Cancel, '#call' do
  let(:api) { double(Api) }
  let(:appointment) { double(Appointment, process_genesys_creation!: true) }

  before do
    allow(api).to receive(:push).with(appointment, rescheduling: true).and_return('deadbeef')
  end

  subject { described_class.new(appointment, api:) }

  it 'pushes the cancellation and clears the genesys operation ID' do
    subject.call

    expect(appointment).to have_received(:process_genesys_creation!).with('')
  end
end
