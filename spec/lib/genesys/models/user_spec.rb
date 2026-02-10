require 'rails_helper'

RSpec.describe Genesys::Models::User do
  let(:user_hash) do
    {
      'id' => '17cf0981-df81-4407-9bac-fedca56c8755',
      'selfUri' => '/api/v2/users/17cf0981-df81-4407-9bac-fedca56c8755'
    }
  end

  subject { described_class.new(user_hash) }

  it 'maps `id`' do
    expect(subject.id).to eq('17cf0981-df81-4407-9bac-fedca56c8755')
  end

  it 'maps `selfUri`' do
    expect(subject.self_uri).to eq('/api/v2/users/17cf0981-df81-4407-9bac-fedca56c8755')
  end

  describe '#to_h' do
    it 'maps to the correct API payload' do
      expect(subject.to_h).to eq({ 'userId' => '17cf0981-df81-4407-9bac-fedca56c8755' })
    end
  end
end
