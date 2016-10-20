require 'rails_helper'

RSpec.describe CreateHolidays do
  describe 'validations' do
    subject do
      subject = described_class.new
      subject.validate
      subject
    end

    it 'validates presence of title' do
      expect(subject.errors[:title]).to_not be_empty
    end

    it 'validates presence of date_range' do
      expect(subject.errors[:date_range]).to_not be_empty
    end

    it 'validates presence of user_ids' do
      expect(subject.errors[:user_ids]).to_not be_empty
    end
  end

  describe '#call' do
    it 'creates holidays for users' do
      users = create_list(:guider, 2)
      range = '20/10/2016 08:00 AM - 20/10/2016 01:00 PM'
      start_at = Time.zone.parse('2016-10-20 08:00:00.000000000 +0000')
      end_at = Time.zone.parse('2016-10-20 13:00:00.000000000 +0000')

      CreateHolidays.new(
        title: 'Holiday name',
        date_range: range,
        user_ids: users.map(&:id)
      ).call

      expected_holidays = Holiday.all.order(:user_id)

      expect(expected_holidays.first).to have_attributes(
        title: 'Holiday name',
        user: users.first,
        start_at: start_at,
        end_at: end_at
      )
      expect(expected_holidays.second).to have_attributes(
        title: 'Holiday name',
        user: users.second,
        start_at: start_at,
        end_at: end_at
      )
    end
  end
end
