FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Team #{n}" }
    organisation_content_id { User::TPAS_ORGANISATION_ID }
  end
end
