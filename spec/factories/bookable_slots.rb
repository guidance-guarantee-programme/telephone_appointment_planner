FactoryBot.define do
  factory :bookable_slot do
    start_at { Time.zone.now }
    end_at { start_at + 1.hour }
    guider { create(:guider) }

    trait :tp do
      guider { create(:guider, :tp) }
    end

    trait :cas do
      guider { create(:guider, :cas) }
    end

    trait :ni do
      guider { create(:guider, :ni) }
    end

    trait :wallsend do
      guider { create(:guider, :wallsend) }
    end

    trait :lancs_west do
      guider { create(:guider, :lancs_west) }
    end
  end
end
