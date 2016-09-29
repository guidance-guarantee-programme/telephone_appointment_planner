FactoryGirl.define do
  factory :schedule do
    user { build(:user) }
    from 6.weeks.from_now
  end
end
