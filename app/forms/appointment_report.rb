require 'csv'

class AppointmentReport
  include ActiveModel::Model
  include Report

  attr_reader :where
  attr_reader :date_range

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
    @where = params.fetch(:where, :created_at)
    @date_range = params[:date_range]
  end

  def generate
    CSV.generate do |csv|
      csv << EXPORTABLE_ATTRIBUTES

      appointments.each do |appointment|
        presenter = AppointmentCsvPresenter.new(appointment)
        csv << EXPORTABLE_ATTRIBUTES.map { |a| presenter.public_send(a) }
      end
    end
  end

  def file_name
    "report-#{range_title}#{where}.csv"
  end

  private

  def appointments
    appointments = Appointment.includes(:agent, :guider).order(where)
    appointments.where(where => range) if range
  end
end
