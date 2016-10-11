FactoryGirl.define do
  factory :appointment do
    start_at { Time.zone.now }
    end_at { Time.zone.now + 1.hour }
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    phone '932009320'
    memorable_word 'lozenge'
    guider { build(:user) }
    where_did_you_hear_about_pension_wise 'Somewhere'
  end
end
