require 'rails_helper'

RSpec.describe Casebook::Cancel, '#call' do
  it 'calls the casebook API and processes the response' do
    casebook_api = instance_double(Casebook::Api)
    appointment  = instance_double(Appointment)

    expect(casebook_api).to receive(:cancel).with(appointment)
    expect(appointment).to receive(:process_casebook_cancellation!)

    described_class.new(appointment, api: casebook_api).call
  end
end
