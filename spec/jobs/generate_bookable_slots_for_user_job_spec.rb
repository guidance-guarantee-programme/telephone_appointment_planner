require 'rails_helper'

RSpec.describe GenerateBookableSlotsForUserJob, '#perform' do
  let(:guiders) do
    create_list(:guider, 2)
  end

  it 'generates bookable slots for guiders' do
    allow(BookableSlot).to receive(:generate_for_guider)
    described_class.new.perform(*guiders)

    guiders.each do |guider|
      expect(BookableSlot).to have_received(:generate_for_guider).with(guider)
    end
  end
end
