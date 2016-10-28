FactoryGirl.define do
  factory :slot do
    day_of_week 3
    start_hour 9
    start_minute 0
    end_hour 10
    end_minute 30

    factory :nine_thirty_slot do
      start_hour 9
      start_minute 30
      end_hour 10
      end_minute 40
    end

    factory :four_fifteen_slot do
      start_hour 16
      start_minute 15
      end_hour 17
      end_minute 15
    end
  end
end
