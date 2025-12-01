# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :bookable_slot do
    start_at { Time.zone.now }
    end_at { start_at + 1.hour }
    guider { create(:guider) }

    trait :waltham_forest do
      guider { create(:guider, :waltham_forest) }
    end

    trait :tp do
      guider { create(:guider, :tp) }
    end

    trait :cas do
      guider { create(:guider, :cas) }
    end

    trait :ni do
      guider { create(:guider, :ni) }
    end

    trait :north_tyneside do
      guider { create(:guider, :north_tyneside) }
    end

    trait :lancashire_west do
      guider { create(:guider, :lancashire_west) }
    end

    trait :derbyshire_districts do
      guider { create(:guider, :derbyshire_districts) }
    end

    trait :due_diligence do
      schedule_type { User::DUE_DILIGENCE_SCHEDULE_TYPE }
      guider { create(:guider, :due_diligence) }
    end
  end
end
# rubocop:enable Metrics/BlockLength
