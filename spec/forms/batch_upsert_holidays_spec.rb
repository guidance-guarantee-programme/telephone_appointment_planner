require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe BatchUpsertHolidays do
  describe 'validations' do
    subject do
      described_class.new(
        start_at: Time.zone.now,
        end_at: Time.zone.now + 1.hour
      ).tap(&:validate)
    end

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
          users: users.map(&:id),
          title: 'Holiday name',
          all_day:,
          multi_day_start_at: '20/10/2016',
          multi_day_end_at: '20/10/2016'
        }
      end

      let(:start_at) do
        Time.zone.parse('2016-10-20 00:00:00.000000000 +0000')
      end

      let(:end_at) do
        Time.zone.parse('2016-10-20 23:59:59.999999000 +0000')
      end

      it 'validates end_at is after start_at' do
        subject = described_class.new(
          options.merge(
            multi_day_start_at: '20/10/2016',
            multi_day_end_at: '19/10/2016'
          )
        )
        subject.validate
        expect(subject.errors[:multi_day_end_at]).to_not be_empty
      end

      it 'creates holidays for users' do
        described_class.new(options).call

        expect(results.first).to have_attributes(
          title: 'Holiday name',
          all_day: true,
          user: users.first,
          start_at:,
          end_at:
        )
        expect(results.second).to have_attributes(
          title: 'Holiday name',
          all_day: true,
          user: users.second,
          start_at:,
          end_at:
        )
      end

      context 'with previous holidays' do
        it 'destroys the old holidays' do
          previous_holidays = create_list(:holiday, 2).pluck(:id)
          described_class.new(
            options.merge(previous_holidays:)
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
          users: users.map(&:id),
          title: 'Holiday name',
          all_day:,
          single_day_start_at: '12/10/2016',
          'single_day_start_at(4i)': '12',
          'single_day_start_at(5i)': '0',
          'single_day_end_at(4i)': '14',
          'single_day_end_at(5i)': '0'
        }
      end

      let(:start_at) do
        Time.zone.parse('2016-10-12 12:00:00.000000000 +0000')
      end

      let(:end_at) do
        Time.zone.parse('2016-10-12 14:00:00.000000000 +0000')
      end

      it 'validates end_at is after start_at' do
        subject = described_class.new(
          options.merge(
            single_day_start_at: '12/10/2016',
            'single_day_start_at(4i)': 14,
            'single_day_start_at(5i)': 0,
            'single_day_end_at(4i)': 10,
            'single_day_end_at(5i)': 0
          )
        )
        subject.validate
        expect(subject.errors[:single_day_end_at]).to_not be_empty
      end

      it 'creates holidays for users' do
        described_class.new(options).call

        expect(results.first).to have_attributes(
          title: 'Holiday name',
          all_day: false,
          user: users.first,
          start_at:,
          end_at:
        )
        expect(results.second).to have_attributes(
          title: 'Holiday name',
          all_day: false,
          user: users.second,
          start_at:,
          end_at:
        )
      end

      context 'with previous holidays' do
        it 'destroys the old holidays' do
          previous_holidays = create_list(:holiday, 2).pluck(:id)
          described_class.new(
            options.merge(previous_holidays:)
          ).call

          expect(results.count).to eq 2
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
