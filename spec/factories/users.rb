require 'securerandom'

FactoryGirl.define do
  factory :user do
    uid { SecureRandom.uuid }
    name { Faker::Name.name }
    email 'some-name@example.org'

    permissions ['signin']

    factory :guider_and_resource_manager do
      permissions { [User::RESOURCE_MANAGER_PERMISSION, User::GUIDER_PERMISSION] }
    end

    factory :resource_manager do
      permissions { Array(User::RESOURCE_MANAGER_PERMISSION) }
    end

    factory :guider do
      permissions { Array(User::GUIDER_PERMISSION) }
    end

    factory :agent do
      permissions { Array(User::AGENT_PERMISSION) }
    end
  end
end
