FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "Team #{n}" }
  end
end
