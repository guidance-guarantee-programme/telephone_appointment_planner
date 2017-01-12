require 'csv'

class AppointmentReport
  include ActiveModel::Model
  include Report

  attr_reader :where
  attr_reader :date_range

  validates :date_range, presence: true

  def initialize(params = {})
    @where = params.fetch(:where, :created_at)
    @date_range = params[:date_range]
  end

  def generate # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    column = where == 'created_at' ? 'appointments.created_at' : 'appointments.start_at'

    Appointment
      .select("to_char(appointments.created_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS created_at")
      .select('agents.name AS booked_by')
      .select('guiders.name AS guider')
      .select("to_char(appointments.start_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS date")
      .select(<<-SQL
                CONCAT(
                  (
                    DATE_PART('hour', appointments.end_at - appointments.start_at) * 60 +
                    DATE_PART('minute', appointments.end_at - appointments.start_at)
                  )::text,
                  ' minutes'
                )
                AS duration
              SQL
             )
      .select(<<-SQL
                CASE appointments.status
                  #{Appointment.statuses.map { |k, v| "WHEN #{v} THEN '#{k}'" }.join("\n")}
                END
                AS status
              SQL
             )
      .select('appointments.first_name')
      .select('appointments.last_name')
      .select('appointments.notes')
      .select('appointments.opt_out_of_market_research::text')
      .select('appointments.date_of_birth')
      .select('appointments.id AS booking_reference')
      .select('appointments.memorable_word')
      .select('appointments.phone')
      .select('appointments.mobile')
      .select('appointments.email')
      .where("#{column} >= ? AND #{column} <= ?", range.begin, range.end.end_of_day)
      .joins('INNER JOIN users guiders ON guiders.id = appointments.guider_id')
      .joins('INNER JOIN users agents ON agents.id = appointments.agent_id')
      .order(where)
  end

  def file_name
    "report-#{range_title}#{where}.csv"
  end
end
