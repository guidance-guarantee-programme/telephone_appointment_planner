class AppointmentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attribute :id
  attribute :start_at, key: :start
  attribute :end_at, key: :end
  attribute :title
  attribute :memorable_word
  attribute :phone
  attribute :url, if: -> { instance_options[:include_links] }
  attribute :status
  attribute :cancelled
  attribute :guider_id, key: :resourceId

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
