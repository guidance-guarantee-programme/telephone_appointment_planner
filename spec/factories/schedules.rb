FactoryGirl.define do
  factory :schedule do
    user { build(:user) }
    start_at 6.weeks.from_now

    days = %w(Monday Tuesday Wednesday Thursday Friday)

    trait :with_early_shift do
      slots do
        days.map do |day|
          [
            { start_at: '08:30', end_at: '09:40' },
            { start_at: '09:50', end_at: '11:00' },
            { start_at: '11:20', end_at: '12:30' },
            { start_at: '13:30', end_at: '14:40' },
            { start_at: '14:50', end_at: '16:00' }
          ].map do |v|
            build(:slot, day: day, start_at: v[:start_at], end_at: v[:end_at])
          end
        end.flatten
      end
    end
    trait :with_mid_shift do
      slots do
        days.map do |day|
          [
            { start_at: '09:30', end_at: '10:40' },
            { start_at: '10:50', end_at: '12:00' },
            { start_at: '12:20', end_at: '13:30' },
            { start_at: '14:30', end_at: '15:40' },
            { start_at: '15:50', end_at: '17:00' }
          ].map do |v|
            build(:slot, day: day, start_at: v[:start_at], end_at: v[:end_at])
          end
        end.flatten
      end
    end
    trait :with_late_shift do
      slots do
        days.map do |day|
          [
            { start_at: '11:00', end_at: '12:10' },
            { start_at: '12:20', end_at: '13:30' },
            { start_at: '13:50', end_at: '15:00' },
            { start_at: '16:00', end_at: '17:10' },
            { start_at: '17:20', end_at: '18:30' }
          ].map do |v|
            build(:slot, day: day, start_at: v[:start_at], end_at: v[:end_at])
          end
        end.flatten
      end
    end
  end
end
