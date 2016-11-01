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
    :notes,
    :opt_out_of_market_research,
    :date_of_birth,
    :booking_reference,
    :memorable_word,
    :phone,
    :mobile,
    :email
  ].freeze

  def initialize(params = {})
    @where = params[:where]
    @date_range = params[:date_range]
  end

  def generate
    field = where.to_sym
    appointments = Appointment.all.order(field)
    appointments = appointments.where(field => range) if range
    CSV.generate do |csv|
      csv << EXPORTABLE_ATTRIBUTES
      appointments.each do |appointment|
        presenter = AppointmentCsvPresenter.new(appointment)
        csv << EXPORTABLE_ATTRIBUTES.map { |a| presenter.send(a) }
      end
    end
  end

  def file_name
    integer_range = range ? "#{range.begin.to_i}-#{range.end.to_i}" : nil
    "report-#{integer_range}#{where}.csv"
  end

  private

  def range
    start_at, end_at = date_range.split(' - ').map do |d|
      Time.zone.strptime(d, DATE_RANGE_PICKER_FORMAT)
    end
    start_at..end_at if start_at && end_at
  end
end
