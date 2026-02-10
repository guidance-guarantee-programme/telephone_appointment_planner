require 'rails_helper'

RSpec.describe Genesys::Models::Metadata do
  let(:metadata_hash) do
    { 'version' => 1 }
  end

  subject { described_class.new(metadata_hash) }

  it 'maps the attributes' do
    expect(subject.version).to eq(1)
  end

  describe '#to_h' do
    it 'maps to the correct API payload' do
      expect(subject.to_h).to eq(metadata_hash)
    end
  end
end
