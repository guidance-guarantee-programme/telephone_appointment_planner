FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "Team #{n}" }
  end
end
