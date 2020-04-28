class AppointmentSearch
  def initialize(query, start_at, end_at, current_user, processed)
    @query = query
    @start_at = start_at
    @end_at = end_at
    @current_user = current_user
    @processed = processed
  end

  def search
    results = @query.present? ? search_with_query : search_without_query
    results = within_date_range(results)
    results = for_current_user(results)

    return results if results.count == 1

    processed_for_current_user(results)
  end

  private

  attr_reader :current_user

  def processed_for_current_user(results)
    return results if current_user.tpas? || @processed.blank?

    if @processed == 'yes'
      results.where.not(processed_at: nil)
    else
      results.where(processed_at: nil)
    end
  end

  def for_current_user(results)
    return results if current_user.tp_agent?

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
    if @start_at && @end_at
      results
        .where('start_at > ?', @start_at)
        .where('end_at < ?', @end_at)
    else
      results
    end
  end

  def search_without_query
    Appointment
      .includes(:guider)
      .order(created_at: :desc)
  end

  def search_with_query
    Appointment
      .joins(:guider)
      .includes(:guider)
      .select('appointments.*')
      .where(ilike(%w(appointments.id appointments.first_name appointments.last_name users.name)))
  end
end
