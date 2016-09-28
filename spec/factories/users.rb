require 'securerandom'

FactoryGirl.define do
  factory :user do
    uid { SecureRandom.uuid }
    name { Faker::Name.name }
    email 'some-name@example.org'
    factory :resource_manager_user do
      permissions { Array(User::RESOURCE_MANAGER_PERMISSION) }
    end

    factory :guider_user do
      permissions { Array(User::GUIDER_PERMISSION) }
    end
  end
end
