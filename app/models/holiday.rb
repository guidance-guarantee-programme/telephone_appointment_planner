class Holiday < ApplicationRecord
  acts_as_copy_target

  belongs_to :user, optional: true

  validates :user, presence: true, unless: :bank_holiday?
  validates :all_day, inclusion: [true, false]
  validates :start_at, presence: true
  validates :end_at, presence: true

  def self.merged_for_calendar_view(start_at, end_at, user) # rubocop:disable Metrics/MethodLength
    select(
      <<-SQL
        DISTINCT ON(holidays.bank_holiday, holidays.all_day, holidays.start_at, holidays.end_at, holidays.title)
        holidays.bank_holiday, holidays.all_day, holidays.title, holidays.start_at, holidays.end_at,
        string_agg(holidays.id::text, ',') as holiday_ids
      SQL
    )
      .joins('LEFT JOIN users ON users.id = holidays.user_id')
      .where(users: { organisation_content_id: [user.organisation_content_id, nil] })
      .where('(holidays.start_at, holidays.end_at) OVERLAPS (?, ?)', start_at, end_at)
      .group(:bank_holiday, :all_day, :start_at, :end_at, :title)
      .order(:start_at)
  end

  def self.scoped_for_user_including_bank_holidays(user)
    where('(user_id = ? OR bank_holiday = true)', user.id)
  end

  def self.overlapping_or_inside(start_at, end_at, user)
    includes(:user)
      .where(users: { organisation_content_id: [user.organisation_content_id, nil] })
      .where('(holidays.start_at, holidays.end_at) OVERLAPS (?, ?)', start_at, end_at)
  end

  def holiday_ids
    attributes['holiday_ids']
  end
end
