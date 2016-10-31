class HolidaySerializer < ActiveModel::Serializer
  attribute :id
  attribute :title
  attribute :start_at, key: :start
  attribute :end_at, key: :end
  attribute :holiday_ids
  attribute :user_id, key: :resourceId
  attribute :resourceId do
    object.try(:user_id)
  end
end
