class AppointmentSearch
  REFERENCE_REGEX = /\A\d{1,7}\z/

  def initialize(query, start_at, end_at, current_user, processed, appointment_type) # rubocop:disable Metrics/ParameterLists
    @query = query
    @start_at = start_at
    @end_at = end_at
    @current_user = current_user
    @processed = processed
    @appointment_type = appointment_type
  end

  def search
    results = @query.present? ? search_with_query : search_without_query
    results = within_date_range(results)
    results = for_current_user(results)
    results = for_appointment_type(results)

    return results if results.count == 1

    processed_for_current_user(results)
  end

  private

  attr_reader :current_user

  def for_appointment_type(results)
    case @appointment_type
    when 'pension_wise'
      results.for_pension_wise
    when 'due_diligence'
      results.for_due_diligence
    else
      results
    end
  end

  def processed_for_current_user(results)
    return results if current_user.tpas? || @processed.blank?

    if @processed == 'yes'
      results.where.not(processed_at: nil)
    else
      results.where(processed_at: nil)
    end
  end

  def for_current_user(results)
    return results.for_pension_wise if current_user.tp_agent?
    return results if current_user.tpas_agent?

    results.where(users: { organisation_content_id: current_user.organisation_content_id })
  end

  def ilike(columns)
    query_parts = @query.split(' ')
    conditions = columns.map do |column|
      query_parts.map do |query_part|
        ActiveRecord::Base.send(:sanitize_sql_array, ["#{column}::text ILIKE ?", "%#{query_part}%"])
      end
    end
    conditions.flatten.join(' OR ')
  end

  def within_date_range(results)
    @start_at ||= 3.months.ago.beginning_of_day
    @end_at ||= 3.months.from_now.end_of_day

    results.where('start_at between ? and ?', @start_at, @end_at)
  end

  def search_without_query
    Appointment
      .includes(:guider)
      .order(created_at: :desc)
  end

  def search_with_query
    scope = Appointment.joins(:guider).includes(:guider).select('appointments.*')

    if REFERENCE_REGEX === @query
      scope.where(id: @query)
    else
      scope.where(ilike(%w[appointments.first_name appointments.last_name users.name]))
    end
  end
end
