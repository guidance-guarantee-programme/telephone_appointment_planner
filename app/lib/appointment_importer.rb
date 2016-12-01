class AppointmentImporter
  FAKE_DATE_OF_BIRTH = '1950-01-01'.freeze

  def initialize(row)
    @row = row
  end

  def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    return if Appointment.exists?(row.booking_reference)

    Appointment.without_auditing do
      Appointment.new(
        id: row.booking_reference,
        start_at: row.start_at,
        end_at: row.end_at,
        first_name: row.first_name,
        last_name: row.last_name,
        email: row.email,
        phone: row.phone,
        mobile: row.mobile,
        date_of_birth: FAKE_DATE_OF_BIRTH,
        memorable_word: row.memorable_word,
        status: row.pension_wise_status,
        opt_out_of_market_research: row.opt_out_of_market_research,
        notes: row.notes,
        agent: agent,
        guider: guider
      ).save(validate: false)
    end
  end

  private

  def agent
    User.find_or_create_by!(name: 'Pension Wise Importer')
  end

  def guider
    GuiderImporter.new(row.guider).call
  end

  attr_reader :row
end
