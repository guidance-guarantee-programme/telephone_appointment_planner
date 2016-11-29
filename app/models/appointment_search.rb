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
    columns.map do |c|
      ActiveRecord::Base.send(:sanitize_sql_array, ["#{c}::text ILIKE ?", "%#{@query}%"])
    end.join(' OR ')
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
