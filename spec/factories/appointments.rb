FactoryGirl.define do
  factory :appointment do
    user { build(:guider) }
    start_at { Time.zone.now }
    end_at { Time.zone.now + 1.hour }
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    phone '932009320'
    memorable_word 'lozenge'
  end
end
