FactoryGirl.define do
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
    opt_out_of_market_research true
    memorable_word 'lozenge'
    date_of_birth '1945-01-01'
    guider { create(:guider) }

    factory :imported_appointment do
      date_of_birth AppointmentImporter::FAKE_DATE_OF_BIRTH
    end
  end
end
