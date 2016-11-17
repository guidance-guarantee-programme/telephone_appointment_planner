class HolidaySerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attribute :id
  attribute :title
  attribute :start_at, key: :start
  attribute :end_at, key: :end
  attribute :holiday_ids
  attribute :user_id, key: :resourceId
  attribute :resourceId do
    object.try(:user_id)
  end

  attribute :all_day, key: :allDay

  attribute :url, unless: :bank_holiday? do
    edit_holiday_path(object.holiday_ids || object.id)
  end

  delegate :bank_holiday?, to: :object
end
