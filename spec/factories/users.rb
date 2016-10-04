require 'securerandom'

FactoryGirl.define do
  factory :user do
    uid { SecureRandom.uuid }
    name { Faker::Name.name }
    email 'some-name@example.org'

    factory :resource_manager do
      permissions { Array(User::RESOURCE_MANAGER_PERMISSION) }
    end

    factory :guider do
      permissions { Array(User::GUIDER_PERMISSION) }
    end

    factory :contact_centre_agent do
      permissions { Array(User::CONTACT_CENTRE_AGENT_PERMISSION) }
    end
  end
end
