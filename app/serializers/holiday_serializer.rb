class HolidaySerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attribute :id
  attribute :title
  attribute :bank_holiday
  attribute :start_at, key: :start
  attribute :end_at, key: :end
  attribute :holiday_ids
  attribute :user_id, key: :resourceId
  attribute :resourceId do
    object.try(:user_id)
  end
end
