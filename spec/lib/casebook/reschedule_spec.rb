require 'rails_helper'

RSpec.describe Casebook::Reschedule, '#call' do
  it 'calls the casebook API and processes the response' do
    casebook_api = instance_double(Casebook::Api)
    appointment  = instance_double(Appointment)
    response     = instance_double(Casebook::Response)

    expect(casebook_api).to receive(:reschedule).with(appointment).and_return(response)
    expect(appointment).to receive(:process_casebook!).with(response).and_return(true)

    described_class.new(appointment, api: casebook_api).call
  end
end
