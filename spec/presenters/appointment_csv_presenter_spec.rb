require 'rails_helper'

RSpec.describe AppointmentCsvPresenter do
  context 'when the appointment is rescheduled' do
    it 'answers to the correct letter type' do
      @appointment = build(:appointment, rescheduled_at: Time.zone.now)
      @presenter   = described_class.new(@appointment)

      expect(@presenter.to_h).to include('Letter type' => 'Rescheduled')
    end
  end
end
