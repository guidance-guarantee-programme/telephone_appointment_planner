class Schedule < ApplicationRecord
  belongs_to :user
  has_many :slots, inverse_of: :schedule, dependent: :destroy
  accepts_nested_attributes_for :slots, allow_destroy: true
  scope :by_start_at, -> { order(:start_at) }

  validates :start_at, presence: true
  validate :start_at_must_be_more_than_six_weeks_in_the_future, unless: :first_schedule?

  def end_at
    self[:end_at] - 1.second if self[:end_at]
  end

  def self.with_end_at
    select('*, LEAD(start_at) OVER (ORDER BY start_at) AS end_at')
  end

  def modifiable?
    start_at > 6.weeks.from_now
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
