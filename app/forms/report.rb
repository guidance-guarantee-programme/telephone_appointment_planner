require 'csv'

class Report
  include ActiveModel::Model
  include ActionView::Helpers::DateHelper

  attr_reader :where
  attr_reader :date_range

  DATE_RANGE_PICKER_FORMAT = '%e/%m/%Y'.freeze
  EXPORTABLE_ATTRIBUTES = [
    :created_at,
    :booked_by,
    :guider,
    :date,
    :duration,
    :status,
    :first_name,
    :last_name,
    :date_of_birth,
    :booking_reference,
    :memorable_word,
    :telephone,
    :mobile,
    :email
  ].freeze

  def initialize(params = {})
    @where = params[:where]
    @date_range = params[:date_range]
  end

  def generate
    field = where.to_sym
    start_at, end_at = date_range.split(' - ').map do |d|
      Time.zone.strptime(d, DATE_RANGE_PICKER_FORMAT)
    end
    range = start_at..end_at

    appointments = Appointment.where(field => range).order(field)
    CSV.generate do |csv|
      csv << EXPORTABLE_ATTRIBUTES
      appointments.each do |appointment|
        csv << [
          appointment.created_at,
          appointment.agent.name,
          appointment.guider.name,
          appointment.start_at,
          "#{((appointment.end_at - appointment.start_at) / 1.minute).round} minutes",
          appointment.status,
          appointment.first_name,
          appointment.last_name,
          appointment.date_of_birth,
          appointment.id,
          appointment.memorable_word,
          appointment.phone,
          appointment.mobile,
          appointment.email
        ]
      end
    end
  end
end
