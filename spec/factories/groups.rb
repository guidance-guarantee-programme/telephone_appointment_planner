FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Team #{n}" }
    organisation_content_id { Provider::TPAS.id }
  end
end
