require 'rails_helper'

RSpec.describe Casebook::Api do
  context 'when pushing a valid appointment' do
    it 'returns the casebook appointment identifier'
  end

  context 'when cancelling an appointment' do
    it 'destroys the appointment'
  end

  context 'when rescheduling an existing appointment' do
    it 'reschedules the appointment'
  end
end