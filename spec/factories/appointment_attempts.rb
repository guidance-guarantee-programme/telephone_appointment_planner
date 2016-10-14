FactoryGirl.define do
  factory :appointment_attempt do
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    date_of_birth { 50.years.ago }
    defined_contribution_pot true
  end
end
