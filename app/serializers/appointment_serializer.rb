class AppointmentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attribute :id
  attribute :start_at, key: :start
  attribute :end_at, key: :end
  attribute :title
  attribute :memorable_word
  attribute :phone
  attribute :url
  attribute :status
  attribute :cancelled
  attribute :guider_id, key: :resourceId
  attribute :pension_wise?, key: :pensionWise
  attribute :extended_duration?, key: :extendedDuration

  def title
    "#{object.first_name} #{object.last_name}"
  end

  def url
    edit_appointment_path(object)
  end

  def cancelled
    object.cancelled?
  end
end
