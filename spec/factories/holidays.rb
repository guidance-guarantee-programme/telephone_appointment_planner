FactoryGirl.define do
  factory :holiday do
    title { Faker::Book.title }
    bank_holiday false
    user { create(:guider) }

    factory :bank_holiday do
      bank_holiday true
      user nil
    end
  end
end
