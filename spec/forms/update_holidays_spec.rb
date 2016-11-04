require 'rails_helper'

RSpec.describe UpdateHolidays do
  describe 'validations' do
    subject { described_class.new([]).tap(&:validate) }

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

    let(:results) do
      Holiday.all.order(:user_id)
    end

    let(:old_holidays) do
      users.map do |user|
        create(:holiday, user: user)
      end
    end

    it 'updates holidays' do
      new_users = create_list(:guider, 2)
      new_title = 'New Holiday Title'
      new_start_at = Time.zone.parse('2016-10-20 08:00:00.000000000 +0000')
      new_end_at = Time.zone.parse('2016-10-20 13:00:00.000000000 +0000')

      described_class.new(
        old_holidays.pluck(:id),
        new_title,
        '20/10/2016 08:00 - 20/10/2016 13:00',
        new_users.map(&:id)
      ).call

      expect(results.count).to eq 2
      expect(results.first).to have_attributes(
        title: new_title,
        user: new_users.first,
        start_at: new_start_at,
        end_at: new_end_at
      )
      expect(results.second).to have_attributes(
        title: new_title,
        user: new_users.second,
        start_at: new_start_at,
        end_at: new_end_at
      )
    end
  end
end
