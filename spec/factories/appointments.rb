FactoryBot.define do
  factory :appointment do
    agent { create(:agent) }
    start_at { BusinessDays.from_now(3).at_midday }
    end_at { start_at + 1.hour }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email 'someone@example.com'
    phone '0208 252 4758'
    mobile '07715 930 444'
    notes 'This customer is very nice.'
    gdpr_consent 'yes'
    dc_pot_confirmed true
    memorable_word 'lozenge'
    date_of_birth '1945-01-01'
    type_of_appointment '50-54'
    guider { create(:guider) }
    where_you_heard { WhereYouHeard.options_for_inclusion.sample }
    created_at { 1.day.ago }

    factory :imported_appointment do
      date_of_birth Appointment::FAKE_DATE_OF_BIRTH
    end

    trait :api do
      agent { create(:pension_wise_api_user) }
    end

    trait :with_address do
      email ''
      address_line_one '10 Some Road'
      address_line_two 'Some Street'
      address_line_three 'Somewhere'
      town 'Some Town'
      county 'Some County'
      postcode 'E3 3NN'
    end
  end
end
