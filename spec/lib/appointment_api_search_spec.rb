require 'rails_helper'

RSpec.describe AppointmentApiSearch do
  context 'with a blank query' do
    it 'returns an empty array' do
      expect(described_class.new('').call).to eq([])
    end
  end

  context 'with a reference number' do
    it 'returns the matching result' do
      @appointment = create(:appointment)

      expect(described_class.new(@appointment.id).call).to eq([@appointment])
    end
  end

  context 'with a name or email' do
    it 'returns the matching results' do
      @appointment = create(:appointment, last_name: 'Jones')
      @other       = create(:appointment, last_name: 'Smith', email: 'bleh@example.com')

      # by name
      expect(described_class.new('jones').call).to eq([@appointment])
      # by email
      expect(described_class.new('bleh@exam').call).to eq([@other])
    end
  end
end
