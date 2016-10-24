class Schedule < ApplicationRecord
  belongs_to :user
  has_many :slots, inverse_of: :schedule, dependent: :destroy
  accepts_nested_attributes_for :slots, allow_destroy: true
  scope :by_start_at, -> { order(:start_at) }

  validates :start_at, presence: true
  validates :start_at, uniqueness: { scope: :user_id }

  def self.active(day)
    order(:start_at)
      .where('schedules.start_at <= ?', day)
      .last
  end

  after_initialize :set_default_start_at
  def set_default_start_at
    self.start_at ||= 6.weeks.from_now + 1.day
  end

  def end_at
    self[:end_at] - 1.second if self[:end_at]
  end

  def self.with_end_at
    select('*, LEAD(start_at) OVER (ORDER BY start_at) AS end_at')
  end

  def modifiable?
    return true unless end_at
    end_at > Time.zone.now.end_of_day
  end

  private

  def first_schedule?
    user
      .schedules
      .none?(&:persisted?)
  end
end
