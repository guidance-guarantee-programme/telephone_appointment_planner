class Holiday < ApplicationRecord
  belongs_to :user, required: false

  validates :user, presence: true, unless: :bank_holiday?
  validates :all_day, inclusion: [true, false]

  def self.merged_for_calendar_view
    select(
      <<-SQL
        DISTINCT ON(holidays.bank_holiday, holidays.all_day, holidays.start_at, holidays.end_at, holidays.title)
        holidays.bank_holiday, holidays.all_day, holidays.title, holidays.start_at, holidays.end_at,
        string_agg(holidays.id::text, ',') as holiday_ids
      SQL
    )
      .joins('LEFT JOIN users ON users.id = holidays.user_id')
      .group(:bank_holiday, :all_day, :start_at, :end_at, :title)
      .order(:start_at)
  end

  def self.scoped_for_user_including_bank_holidays(user)
    where('(user_id = ? OR bank_holiday = true)', user.id)
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
