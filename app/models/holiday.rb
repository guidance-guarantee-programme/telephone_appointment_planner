class Holiday < ApplicationRecord
  belongs_to :user, required: false

  validates :user, presence: true, unless: :bank_holiday?

  # rubocop:disable Metrics/MethodLength
  def self.merged_for_calendar_view
    select(
      <<-SQL
        DISTINCT ON(holidays.all_day, holidays.bank_holiday, holidays.start_at, holidays.end_at, holidays.title)
        holidays.all_day, holidays.bank_holiday, holidays.title, holidays.start_at, holidays.end_at,
        holidays.title || COALESCE(' - ' || string_agg(users.name, ', '), '') AS title,
        string_agg(holidays.id::text, ',') as holiday_ids
      SQL
    )
      .joins('LEFT JOIN users ON users.id = holidays.user_id')
      .group(:all_day, :bank_holiday, :start_at, :end_at, :title)
      .order(:start_at)
  end

  def self.overlapping_or_inside(start_at, end_at)
    range = start_at..end_at
    where(start_at: range)
      .or(where(end_at: range))
      .or(where('(start_at < ? AND end_at > ?)', start_at, end_at))
  end

  def holiday_ids
    attributes['holiday_ids']
  end
end
