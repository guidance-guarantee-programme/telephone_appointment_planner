class AppointmentApiSearch
  def initialize(query)
    @query = query
  end

  def call
    return [] if query.blank?
    return search_by_reference if /\A\d+\Z/.match?(query.to_s)

    Appointment
      .where('last_name ILIKE :query OR email ILIKE :query', query: "%#{query}%")
      .order(created_at: :desc)
      .limit(20)
  end

  private

  attr_reader :query

  def search_by_reference
    Appointment.where(id: query)
  end
end
