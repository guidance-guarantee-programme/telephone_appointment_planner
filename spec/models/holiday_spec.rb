require 'rails_helper'

RSpec.describe Holiday, type: :model do
  describe '#merge_for_calendar_view' do
    it 'merges holidays for calendar view' do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      same_start = Time.zone.now
      same_end = 1.hour.from_now
      same_title = 'Same Title'

      different_start = 5.hours.from_now
      different_end = 6.hours.from_now
      different_title = 'Different Title'

      create(:holiday, user: user1, title: same_title, start_at: same_start, end_at: same_end)
      create(:holiday, user: user2, title: same_title, start_at: same_start, end_at: same_end)
      create(:holiday, user: user3, title: different_title, start_at: different_start, end_at: different_end)

      results = Holiday.merged_for_calendar_view

      expect(results.first.title).to eq "#{same_title} - #{user1.name}, #{user2.name}"
      expect(results.first.start_at.to_s).to eq same_start.to_s
      expect(results.first.end_at.to_s).to eq same_end.to_s

      expect(results.second.title).to eq "#{different_title} - #{user3.name}"
      expect(results.second.start_at.to_s).to eq different_start.to_s
      expect(results.second.end_at.to_s).to eq different_end.to_s
    end
  end
end
