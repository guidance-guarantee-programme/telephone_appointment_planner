class Holiday < ApplicationRecord
  belongs_to :user, required: false

  def self.merged_for_calendar_view
    select(<<-SQL
      DISTINCT ON(holidays.start_at, holidays.end_at, holidays.title)
        holidays.title, holidays.start_at, holidays.end_at, holidays.title || ' - ' || string_agg(users.name, ', ') AS title
    SQL
          )
      .joins('LEFT JOIN users ON users.id = holidays.user_id')
      .group(:start_at, :end_at, :title)
      .order(:start_at)
  end
end
