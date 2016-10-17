FactoryGirl.define do
  factory :holiday do
    title { Faker::Book.title }
  end
end
