class AppointmentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attribute :start_at, key: :start
  attribute :end_at, key: :end
  attribute :title
  attribute :memorable_word
  attribute :phone
  attribute :url

  def title
    "#{object.first_name} #{object.last_name}"
  end

  def url
    edit_appointment_path(object)
  end
end
