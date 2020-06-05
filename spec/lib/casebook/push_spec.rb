require 'rails_helper'

RSpec.describe Casebook::Push, '#call' do
  it 'calls the casebook API and processes the response' do
    casebook_api = instance_double(Casebook::Api)
    appointment  = instance_double(Appointment)

    expect(casebook_api).to receive(:create).with(appointment).and_return('123456')
    expect(appointment).to receive(:process_casebook!).with('123456').and_return(true)

    described_class.new(appointment, api: casebook_api).call
  end
end
