FactoryGirl.define do
  factory :holiday do
    title { Faker::Book.title }
    user { create(:guider) }
    bank_holiday false
    all_day false
    start_at { Time.zone.now.at_midday }
    end_at { Time.zone.now.at_midday + 1.hour }

    factory :bank_holiday do
      user nil
      bank_holiday true
      all_day true
    end
  end
end
