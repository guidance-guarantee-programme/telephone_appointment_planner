require 'rails_helper'

RSpec.describe GenerateBookableSlotsForUserJob, '#perform' do
  let(:guider) { create(:guider) }

  it 'generates bookable slots for the given guider' do
    expect(BookableSlot).to receive(:generate_for_guider).with(guider)

    described_class.new.perform(guider)
  end
end
