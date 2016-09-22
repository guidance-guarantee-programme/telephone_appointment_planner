require 'securerandom'

FactoryGirl.define do
  factory :user do
    uid { SecureRandom.uuid }
    name 'Some Name'
    email 'some-name@example.org'
    factory :resource_manager_user do
      permissions { Array(User::RESOURCE_MANAGER_PERMISSION) }
    end
  end
end
