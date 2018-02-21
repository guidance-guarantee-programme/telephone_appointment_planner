require 'securerandom'

FactoryBot.define do
  factory :user do
    uid { SecureRandom.uuid }
    name { Faker::Name.name }
    email 'some-name@example.org'

    permissions ['signin']

    trait :tpas do
      organisation_content_id User::TPAS_ORGANISATION_ID
    end

    trait :tp do
      organisation_content_id User::TP_ORGANISATION_ID
    end

    trait :cas do
      organisation_content_id User::CAS_ORGANISATION_ID
    end

    factory :guider_and_resource_manager do
      organisation_content_id User::TPAS_ORGANISATION_ID
      permissions { [User::RESOURCE_MANAGER_PERMISSION, User::GUIDER_PERMISSION] }
    end

    factory :resource_manager do
      organisation_content_id User::TPAS_ORGANISATION_ID
      permissions { Array(User::RESOURCE_MANAGER_PERMISSION) }
    end

    factory :guider do
      organisation_content_id User::TPAS_ORGANISATION_ID
      permissions { Array(User::GUIDER_PERMISSION) }

      factory :deactivated_guider do
        active false
      end
    end

    factory :agent do
      organisation_content_id User::TP_ORGANISATION_ID
      permissions { Array(User::AGENT_PERMISSION) }
    end

    factory :contact_centre_team_leader do
      organisation_content_id User::TP_ORGANISATION_ID
      permissions { Array(User::CONTACT_CENTRE_TEAM_LEADER_PERMISSION) }
    end

    factory :pension_wise_api_user do
      permissions { Array(User::PENSION_WISE_API_PERMISSION) }
    end
  end
end
