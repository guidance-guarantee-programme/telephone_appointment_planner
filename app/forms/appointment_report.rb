# rubocop:disable LineLength
class AppointmentReport
  include ActiveModel::Model
  include Report

  attr_reader :where
  attr_reader :date_range
  attr_reader :current_user

  validates :date_range, presence: true

  def initialize(params = {})
    @where = params.fetch(:where, :created_at)
    @date_range = params[:date_range]
    @current_user = params[:current_user]
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
      .select('(SELECT MAX(created_at) FROM status_transitions WHERE appointment_id = appointments.id) as status_changed')
      .select(<<-SQL
                CASE WHEN EXISTS(SELECT 1 FROM Activities WHERE type = 'SummaryDocumentActivity' AND appointment_id = appointments.id) THEN 'Yes'
                     ELSE 'No'
                END as summary_document_created
              SQL
             )
      .select('appointments.first_name')
      .select('appointments.last_name')
      .select('appointments.notes')
      .select('appointments.gdpr_consent')
      .select('appointments.date_of_birth')
      .select('appointments.id AS booking_reference')
      .select('appointments.memorable_word')
      .select('appointments.phone')
      .select('appointments.mobile')
      .select('appointments.email')
      .select("case when third_party_booking is true then 'Yes' else 'No' end as third_party_booking")
      .select("case when data_subject_consent_obtained is true then 'Yes' else 'No' end as data_subject_consent_obtained")
      .select(<<-SQL
                case
                when exists(select id from active_storage_attachments where appointments.id = record_id and name = 'data_subject_consent_evidence') is true then 'Yes' else 'No'
                end as data_subject_consent_attached
              SQL
             )
      .select("case when power_of_attorney = true then 'Yes' else 'No' end as power_of_attorney")
      .select(<<-SQL
                case
                when exists(select id from active_storage_attachments where appointments.id = record_id and name = 'power_of_attorney_evidence') is true then 'Yes' else 'No'
                end as power_of_attorney_attached
              SQL
             )
      .select("case when printed_consent_form_required is true then 'Yes' else 'No' end as printed_consent_form_required")
      .select("case when email_consent_form_required is true then 'Yes' else 'No' end as email_consent_form_required")
      .where("#{column} >= ? AND #{column} <= ?", range.begin, range.end.end_of_day)
      .where(organisation_clause)
      .joins('INNER JOIN users guiders ON guiders.id = appointments.guider_id')
      .joins('INNER JOIN users agents ON agents.id = appointments.agent_id')
      .order(where)
  end

  def file_name
    "report-#{range_title}#{where}.csv"
  end

  private

  def organisation_clause
    return '1 = 1' if current_user.contact_centre_team_leader?

    { guiders: { organisation_content_id: current_user.organisation_content_id } }
  end
end
