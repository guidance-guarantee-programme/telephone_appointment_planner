require 'rails_helper'

RSpec.describe Holiday, type: :model do
  describe 'validations' do
    it 'requires all_day' do
      holiday = build_stubbed(:holiday, all_day: nil)
      expect(holiday).to_not be_valid
    end

    it 'requires start_at' do
      holiday = build_stubbed(:holiday, start_at: nil)
      expect(holiday).to_not be_valid
    end

    it 'requires end_at' do
      holiday = build_stubbed(:holiday, end_at: nil)
      expect(holiday).to_not be_valid
    end

    context 'bank holiday' do
      it 'is valid with valid attributes' do
        holiday = build_stubbed(:holiday)
        expect(holiday).to be_valid
      end

      it 'does not require a user' do
        holiday = build_stubbed(:bank_holiday, user: nil)
        expect(holiday).to be_valid
      end
    end

    context 'user holidays' do
      it 'is valid with valid attributes' do
        holiday = build_stubbed(:bank_holiday)
        expect(holiday).to be_valid
      end

      it 'requires a user' do
        holiday = build_stubbed(:holiday, user: nil)
        expect(holiday).to_not be_valid
      end
    end
  end

  describe '#merge_for_calendar_view' do
    let(:resource_manager) { create(:resource_manager) }
    let(:results) do
      subject.class.merged_for_calendar_view(resource_manager)
    end

    it 'merges holidays for calendar view' do
      user1, user2, user3 = create_list(:guider, 3)
      # not owned by this resource manager
      tp_guider = create(:guider, :tp)

      same_start = Time.zone.now
      same_end = 1.hour.from_now
      same_title = 'Same Title'

      different_start = 5.hours.from_now
      different_end = 6.hours.from_now
      different_title = 'Different Title'

      # this will not be included as it's from TP not TPAS
      create(:holiday, user: tp_guider, title: same_title, start_at: same_start + 1, end_at: same_end + 1)
      create(:holiday, user: user1, title: same_title, start_at: same_start, end_at: same_end)
      create(:holiday, user: user2, title: same_title, start_at: same_start, end_at: same_end)
      create(:holiday, user: user3, title: different_title, start_at: different_start, end_at: different_end)

      expect(results.length).to eq(2)
      expect(results.first.title).to eq same_title
      expect(results.first.start_at.to_s).to eq same_start.to_s
      expect(results.first.end_at.to_s).to eq same_end.to_s

      expect(results.second.title).to eq different_title
      expect(results.second.start_at.to_s).to eq different_start.to_s
      expect(results.second.end_at.to_s).to eq different_end.to_s
    end

    it 'lists bank holidays' do
      create(
        :holiday,
        title: 'some other holiday',
        start_at: Date.new(2014, 12, 25).beginning_of_day,
        end_at: Date.new(2014, 12, 25).end_of_day
      )
      christmas = create(
        :bank_holiday,
        title: 'christmas',
        start_at: Date.new(2010, 12, 25).beginning_of_day,
        end_at: Date.new(2010, 12, 25).end_of_day
      )

      expect(results.first.title).to eq christmas.title
      expect(results.first.start_at.to_s).to eq christmas.start_at.to_s
      expect(results.first.end_at.to_s).to eq christmas.end_at.to_s
    end
  end

  describe '#overlapping_or_inside' do
    let(:start_at) do
      Time.zone.now + 5.days
    end

    let(:end_at) do
      start_at + 5.days
    end

    let!(:holiday_starting_in_range) do
      create(
        :bank_holiday,
        start_at: start_at + 3.days,
        end_at: end_at + 5.days
      )
    end

    let!(:holiday_ending_in_range) do
      create(
        :bank_holiday,
        start_at: start_at - 10.days,
        end_at: start_at + 1.day
      )
    end

    let!(:holiday_overlapping_range) do
      create(
        :bank_holiday,
        start_at: start_at - 10.days,
        end_at: end_at + 10.days
      )
    end

    let!(:holiday_not_overlapping_or_inside) do
      create(
        :bank_holiday,
        start_at: start_at + 10.days,
        end_at: end_at + 20.days
      )
    end

    let!(:tp_holiday) do
      create(
        :holiday,
        user: create(:guider, :tp),
        start_at: start_at + 11.days,
        end_at: end_at + 19.days
      )
    end

    let(:result) do
      described_class.overlapping_or_inside(start_at, end_at, resource_manager)
    end

    context 'when viewing as a TPAS manager' do
      let(:resource_manager) { create(:resource_manager) }

      it 'does not include other organisation’s holidays' do
        expect(result).to_not include(tp_holiday)
      end

      it 'does not list holidays not overlapping or inside the range' do
        expect(result).to_not include holiday_not_overlapping_or_inside
      end

      it 'lists holidays starting inside the range' do
        expect(result).to include holiday_starting_in_range
      end

      it 'lists holidays ending inside the range' do
        expect(result).to include holiday_ending_in_range
      end

      it 'lists holidays overlapping the range' do
        expect(result).to include holiday_overlapping_range
      end
    end
  end
end
