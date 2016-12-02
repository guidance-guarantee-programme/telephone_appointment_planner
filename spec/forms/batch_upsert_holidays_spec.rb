require 'rails_helper'

RSpec.describe BatchUpsertHolidays do
  describe 'validations' do
    subject { described_class.new.tap(&:validate) }

    it 'validates presence of title' do
      expect(subject.errors[:title]).to_not be_empty
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

    context 'all day holidays' do
      let(:all_day) do
        true
      end

      let(:options) do
        {
          users:    users.map(&:id),
          title:    'Holiday name',
          all_day:  all_day,
          start_at: '20/10/2016',
          end_at:   '20/10/2016'
        }
      end

      let(:start_at) do
        Time.zone.parse('2016-10-20 00:00:00.000000000 +0000')
      end

      let(:end_at) do
        Time.zone.parse('2016-10-20 00:00:00.000000000 +0000')
      end

      it 'creates holidays for users' do
        described_class.new(options).call

        expect(results.first).to have_attributes(
          title: 'Holiday name',
          all_day: true,
          user: users.first,
          start_at: start_at,
          end_at: end_at
        )
        expect(results.second).to have_attributes(
          title: 'Holiday name',
          all_day: true,
          user: users.second,
          start_at: start_at,
          end_at: end_at
        )
      end

      context 'with previous holidays' do
        it 'destroys the old holidays' do
          previous_holidays = create_list(:holiday, 2).pluck(:id)
          described_class.new(
            options.merge(previous_holidays: previous_holidays)
          ).call

          expect(results.count).to eq 2
        end
      end
    end

    context 'one day holidays' do
      let(:all_day) do
        false
      end

      let(:options) do
        {
          users:          users.map(&:id),
          title:          'Holiday name',
          all_day:        all_day,
          start_at:       '12/10/2016',
          'start_at(4i)': 12,
          'start_at(5i)': 0,
          'end_at(4i)':   14,
          'end_at(5i)':   0
        }
      end

      let(:start_at) do
        Time.zone.parse('2016-10-12 12:00:00.000000000 +0000')
      end

      let(:end_at) do
        Time.zone.parse('2016-10-12 14:00:00.000000000 +0000')
      end

      it 'creates holidays for users' do
        described_class.new(options).call

        expect(results.first).to have_attributes(
          title: 'Holiday name',
          all_day: false,
          user: users.first,
          start_at: start_at,
          end_at: end_at
        )
        expect(results.second).to have_attributes(
          title: 'Holiday name',
          all_day: false,
          user: users.second,
          start_at: start_at,
          end_at: end_at
        )
      end

      context 'with previous holidays' do
        it 'destroys the old holidays' do
          previous_holidays = create_list(:holiday, 2).pluck(:id)
          described_class.new(
            options.merge(previous_holidays: previous_holidays)
          ).call

          expect(results.count).to eq 2
        end
      end
    end
  end
end
