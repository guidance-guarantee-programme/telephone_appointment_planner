require 'rails_helper'

RSpec.describe CreateHolidays do
  describe 'validations' do
    subject { described_class.new.tap(&:validate) }

    it 'validates presence of title' do
      expect(subject.errors[:title]).to_not be_empty
    end

    it 'validates presence of date_range' do
      expect(subject.errors[:date_range]).to_not be_empty
    end

    it 'validates presence of users' do
      expect(subject.errors[:users]).to_not be_empty
    end
  end

  describe '#call' do
    let(:users) do
      create_list(:guider, 2)
    end

    let(:start_at) do
      Time.zone.parse('2016-10-20 08:00:00.000000000 +0000')
    end

    let(:end_at) do
      Time.zone.parse('2016-10-20 13:00:00.000000000 +0000')
    end

    let(:range) do
      '20/10/2016 08:00 AM - 20/10/2016 01:00 PM'
    end

    let(:results) do
      Holiday.all.order(:user_id)
    end

    it 'creates holidays for users' do
      described_class.new(
        'Holiday name',
        range,
        users.map(&:id)
      ).call

      expect(results.first).to have_attributes(
        title: 'Holiday name',
        user: users.first,
        start_at: start_at,
        end_at: end_at
      )
      expect(results.second).to have_attributes(
        title: 'Holiday name',
        user: users.second,
        start_at: start_at,
        end_at: end_at
      )
    end
  end
end
