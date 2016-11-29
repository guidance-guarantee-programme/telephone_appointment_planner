class AppointmentSearch
  def initialize(query, start_at, end_at)
    @query = query
    @start_at = start_at
    @end_at = end_at
  end

  def search
    results = @query.present? ? search_with_query : search_without_query
    within_date_range(results)
  end

  private

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
    Appointment.order(created_at: :desc)
  end

  def search_with_query
    Appointment.select('appointments.*')
               .where(ilike(%w(appointments.id appointments.first_name appointments.last_name users.name)))
               .joins(:guider)
  end
end
