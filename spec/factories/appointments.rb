FactoryGirl.define do
  factory :appointment do
    start_at { 5.days.from_now }
    end_at { 5.days.from_now + 1.hour }
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    phone '932009320'
    memorable_word 'lozenge'
    guider { build(:user) }
    where_did_you_hear_about_pension_wise 'Somewhere'
  end
end
