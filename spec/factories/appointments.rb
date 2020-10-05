FactoryBot.define do
  factory :appointment do
    transient do
      organisation { :tpas }
    end

    agent { create(:resource_manager, organisation) }
    start_at { BusinessDays.from_now(3).at_midday }
    end_at { start_at + 1.hour }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { 'someone@example.com' }
    phone { '0208 252 4758' }
    mobile { '07715 930 444' }
    notes { 'This customer is very nice.' }
    gdpr_consent { 'yes' }
    dc_pot_confirmed { true }
    memorable_word { 'lozenge' }
    date_of_birth { '1945-01-01' }
    type_of_appointment { '50-54' }
    guider { create(:guider, organisation) }
    where_you_heard { WhereYouHeard.options_for_inclusion.sample }
    created_at { 1.day.ago }
    accessibility_requirements { false }
    pension_provider { 'n/a' }

    factory :imported_appointment do
      date_of_birth { Appointment::FAKE_DATE_OF_BIRTH }
    end

    trait :api do
      agent { create(:pension_wise_api_user) }
    end

    trait :with_address do
      email { '' }
      address_line_one { '10 Some Road' }
      address_line_two { 'Some Street' }
      address_line_three { 'Somewhere' }
      town { 'Some Town' }
      county { 'Some County' }
      postcode { 'E3 3NN' }
    end

    trait :processed do
      processed_at { Time.zone.now }
    end

    trait :third_party_booking do
      third_party_booking { true }
      data_subject_name { 'Bob Bobson' }
      data_subject_age { 51 }
    end

    trait :third_party_consent_form_requested do
      printed_consent_form_required { true }

      consent_address_line_one { '1 Some Street' }
      consent_address_line_two { 'Some Place' }
      consent_address_line_three { 'Somewhere' }
      consent_town { 'Some Town' }
      consent_county { 'Some County' }
      consent_postcode { 'SS1 1SS' }
    end

    trait :data_subject_consented do
      data_subject_consent_obtained { true }
    end

    trait :with_data_subject_consent_evidence do
      data_subject_consent_obtained { true }
      data_subject_consent_evidence do
        Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'evidence.pdf'), 'application/pdf')
      end
    end
  end
end
