class AppointmentSearchSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attribute :id, key: :reference
  attribute :name

  attribute :url do
    edit_appointment_url(object)
  end
end
