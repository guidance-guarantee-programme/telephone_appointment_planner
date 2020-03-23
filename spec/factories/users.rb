require 'securerandom'

FactoryBot.define do
  factory :user do
    uid { SecureRandom.uuid }
    name { Faker::Name.name }
    email { 'some-name@example.org' }

    permissions { ['signin'] }

    Provider::ALL_ORGANISATIONS.each do |organisation|
      trait organisation.symbol_name do
        organisation_content_id { organisation.id }
      end
    end

    factory :administrator, traits: [:tpas] do
      permissions { [User::ADMINISTRATOR_PERMISSION] }
    end

    factory :guider_and_resource_manager, traits: [:tpas] do
      permissions { [User::RESOURCE_MANAGER_PERMISSION, User::GUIDER_PERMISSION] }
    end

    factory :agent_and_guider, traits: [:tp] do
      permissions { [User::AGENT_PERMISSION, User::GUIDER_PERMISSION] }
    end

    factory :resource_manager, traits: [:tpas] do
      permissions { Array(User::RESOURCE_MANAGER_PERMISSION) }
    end

    factory :guider, traits: [:tpas] do
      permissions { Array(User::GUIDER_PERMISSION) }

      factory :deactivated_guider do
        active { false }
      end
    end

    factory :agent, traits: [:tp] do
      permissions { Array(User::AGENT_PERMISSION) }
    end

    factory :contact_centre_team_leader, traits: [:tp] do
      permissions { Array(User::CONTACT_CENTRE_TEAM_LEADER_PERMISSION) }
    end

    factory :pension_wise_api_user do
      permissions { Array(User::PENSION_WISE_API_PERMISSION) }
    end
  end
end
