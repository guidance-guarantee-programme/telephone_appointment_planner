require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validations' do
    let(:subject) do
      build_stubbed(:activity)
    end

    it 'is valid with valid parameters' do
      expect(subject).to be_valid
    end

    it 'validates presence of owner' do
      subject.owner = nil
      subject.validate
      expect(subject.errors[:owner]).to_not be_empty
    end
  end
end
