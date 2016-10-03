FactoryGirl.define do
  factory :schedule do
    user { build(:user) }
    start_at 6.weeks.from_now
  end
end
