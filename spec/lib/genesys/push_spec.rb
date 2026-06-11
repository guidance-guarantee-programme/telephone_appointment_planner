require 'rails_helper'

RSpec.describe Genesys::Push, '#call' do
  let(:api) { double(Api) }
  let(:appointment) { double(Appointment, process_genesys_creation!: true) }

  before do
    allow(api).to receive(:push).with(appointment).and_return('deadbeef')
  end

  subject { described_class.new(appointment, api:) }

  it 'pushes and sets the genesys operation ID' do
    subject.call

    expect(appointment).to have_received(:process_genesys_creation!).with('deadbeef')
  end
end
