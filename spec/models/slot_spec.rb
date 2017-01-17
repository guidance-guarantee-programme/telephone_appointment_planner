require 'rails_helper'

RSpec.describe Slot do
  describe 'validations' do
    subject do
      Slot.new(
        day_of_week: 3
      )
    end

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'day_of_week can not fall on a Saturday' do
      subject.day_of_week = 6
      expect(subject).to_not be_valid
    end

    it 'day_of_week can not fall on a Sunday' do
      subject.day_of_week = 0
      expect(subject).to_not be_valid
    end
  end
end
