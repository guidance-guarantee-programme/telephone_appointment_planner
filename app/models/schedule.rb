class Schedule < ApplicationRecord
  belongs_to :user
  has_many :slots, inverse_of: :schedule, dependent: :destroy
  accepts_nested_attributes_for :slots, allow_destroy: true
  scope :by_start_at, -> { order(:start_at) }

  validates :start_at, presence: true
  validates :start_at, uniqueness: { scope: :user_id }
  validate :start_at_must_be_more_than_six_weeks_in_the_future, unless: :first_schedule?

  def self.active(day)
    order(:start_at)
      .where('schedules.start_at <= ?', day)
      .last
  end

  def end_at
    self[:end_at] - 1.second if self[:end_at]
  end

  def self.with_end_at
    select('*, LEAD(start_at) OVER (ORDER BY start_at) AS end_at')
  end

  def modifiable?
    start_at > 6.weeks.from_now
  end

  # rubocop:disable Metrics/MethodLength
  def self.available_slots_with_guider_count(from, to)
    UsableSlot
      .select('DISTINCT usable_slots.start_at, usable_slots.end_at, count(1) AS guiders')
      .joins(<<-SQL
              LEFT JOIN appointments ON
                appointments.user_id = usable_slots.user_id AND
                appointments.start_at = usable_slots.start_at AND
                appointments.end_at = usable_slots.end_at
              SQL
            )
      .group('usable_slots.start_at, usable_slots.end_at')
      .where('appointments.start_at IS NULL')
      .within_date_range(from, to)
      .map do |us|
      { guiders: us.attributes['guiders'], start: us.start_at, end: us.end_at }
    end
  end

  private

  def first_schedule?
    user
      .schedules
      .none?(&:persisted?)
  end

  def start_at_must_be_more_than_six_weeks_in_the_future
    maximum_age = 6.weeks.from_now.beginning_of_day
    older_than_six_weeks = start_at && start_at >= maximum_age
    errors.add(:start_at, 'must be more than six weeks from now') unless older_than_six_weeks
  end
end
