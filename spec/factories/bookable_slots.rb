FactoryGirl.define do
  factory :bookable_slot do
    start_at Time.zone.now
    end_at { start_at + 1.hour }
  end
end
