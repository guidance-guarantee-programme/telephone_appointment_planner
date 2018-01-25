FactoryBot.define do
  factory :schedule do
    user { build(:user) }
    start_at { Time.zone.now.beginning_of_day }

    days = 1.upto(5)

    trait :with_early_shift do
      slots do
        days.map do |day|
          [
            { day_of_week: day, start_hour: 8, start_minute: 30, end_hour: 9, end_minute: 40 },
            { day_of_week: day, start_hour: 9, start_minute: 50, end_hour: 11, end_minute: 0 },
            { day_of_week: day, start_hour: 11, start_minute: 20, end_hour: 12, end_minute: 30 },
            { day_of_week: day, start_hour: 13, start_minute: 30, end_hour: 14, end_minute: 40 },
            { day_of_week: day, start_hour: 14, start_minute: 50, end_hour: 16, end_minute: 0 }
          ].map do |v|
            build(:slot, v)
          end
        end.flatten
      end
    end
    trait :with_mid_shift do
      slots do
        days.map do |day|
          [
            { day_of_week: day, start_hour: 9, start_minute: 30, end_hour: 10, end_minute: 40 },
            { day_of_week: day, start_hour: 10, start_minute: 50, end_hour: 12, end_minute: 0 },
            { day_of_week: day, start_hour: 12, start_minute: 20, end_hour: 13, end_minute: 30 },
            { day_of_week: day, start_hour: 14, start_minute: 30, end_hour: 15, end_minute: 40 },
            { day_of_week: day, start_hour: 15, start_minute: 50, end_hour: 17, end_minute: 0 }
          ].map do |v|
            build(:slot, v)
          end
        end.flatten
      end
    end
    trait :with_late_shift do
      slots do
        days.map do |day|
          [
            { day_of_week: day, start_hour: 11, start_minute: 0, end_hour: 12, end_minute: 10 },
            { day_of_week: day, start_hour: 12, start_minute: 20, end_hour: 13, end_minute: 30 },
            { day_of_week: day, start_hour: 13, start_minute: 50, end_hour: 15, end_minute: 0 },
            { day_of_week: day, start_hour: 16, start_minute: 0, end_hour: 17, end_minute: 10 },
            { day_of_week: day, start_hour: 17, start_minute: 20, end_hour: 18, end_minute: 30 }
          ].map do |v|
            build(:slot, v)
          end
        end.flatten
      end
    end
  end
end
