class Schedule < ApplicationRecord
  belongs_to :user
  has_many :slots, inverse_of: :schedule, dependent: :destroy
  accepts_nested_attributes_for :slots, allow_destroy: true
  scope :by_from, -> { order(:from) }

  validates :from, presence: true
  validate :from_must_be_more_than_six_weeks_in_the_future, unless: :first_schedule?

  def end_at
    self[:end_at] - 1.day if self[:end_at]
  end

  def self.with_end_at
    select('*, LEAD("from", 1) OVER (ORDER BY "from") AS end_at')
      .by_from
  end

  def modifiable?
    from > 6.weeks.from_now
  end

  private

  def first_schedule?
    user
      .schedules
      .none?(&:persisted?)
  end

  def from_must_be_more_than_six_weeks_in_the_future
    maximum_age = 6.weeks.from_now.beginning_of_day
    older_than_six_weeks = from && from >= maximum_age
    errors.add(:from, 'must be more than six weeks from now') unless older_than_six_weeks
  end
end
