class OnlineReschedulingsSearch
  include ActiveModel::Model
  include DateRangePickerHelper

  REFERENCE_REGEX = /\A\d{1,7}\z/

  attr_accessor :q, :date_range, :current_user
  attr_writer :processed

  def results
    results = q.present? ? search_with_query : search_without_query
    results = within_date_range(results)
    results = for_current_user(results)

    processed_for_current_user(results)
  end

  def processed
    return '' if current_user.tpas?

    @processed || 'no'
  end

  private

  def range
    @range ||= date_range
               .to_s
               .split(' - ')
               .map { |d| strp_date_range_picker_date(d) }
  end

  def start_at
    range.first.try(:beginning_of_day) || 3.months.ago.beginning_of_day
  end

  def end_at
    range.last.try(:end_of_day) || 3.months.from_now.end_of_day
  end

  def processed_for_current_user(results)
    return results if current_user.tpas? || processed.blank?

    if processed == 'yes'
      results.where.not(appointment: { processed_at: nil })
    else
      results.where(appointment: { processed_at: nil })
    end
  end

  def for_current_user(results)
    results.where(previous_guider: { organisation_content_id: current_user.organisation_content_id })
  end

  def ilike(columns)
    query_parts = q.split(' ')
    conditions = columns.map do |column|
      query_parts.map do |query_part|
        ActiveRecord::Base.send(:sanitize_sql_array, ["#{column}::text ILIKE ?", "%#{query_part}%"])
      end
    end
    conditions.flatten.join(' OR ')
  end

  def within_date_range(results)
    results.where('previous_start_at between ? and ?', start_at, end_at)
  end

  def search_without_query
    OnlineReschedule
      .includes(:previous_guider)
      .includes(:appointment)
      .order(created_at: :desc)
  end

  def search_with_query
    scope = OnlineReschedule
            .includes(:previous_guider)
            .includes(:appointment)
            .order(created_at: :desc)

    if REFERENCE_REGEX === q
      scope.where(appointment: { id: q })
    else
      scope.where(ilike(%w[appointments.first_name appointments.last_name]))
    end
  end
end
