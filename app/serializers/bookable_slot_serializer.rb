class BookableSlotSerializer < ActiveModel::Serializer
  attribute :start_at, key: :start
  attribute :end_at, key: :end
  attribute :resourceId do
    object.guider_id
  end
  attribute :scheduleType do
    object.schedule_type.dasherize
  end
end
