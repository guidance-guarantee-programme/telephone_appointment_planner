FactoryGirl.define do
  factory :appointment do
    start_at { BusinessDays.from_now(3) }
    end_at { start_at + 1.hour }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone '932009320'
    memorable_word 'lozenge'
    guider { build(:user) }
    where_did_you_hear_about_pension_wise 'Somewhere'
  end
end
