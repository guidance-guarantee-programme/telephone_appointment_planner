class Schedule < ApplicationRecord
  belongs_to :user
  has_many :slots, inverse_of: :schedule, dependent: :destroy
  accepts_nested_attributes_for :slots, allow_destroy: true
  scope :by_start_at, -> { order(:start_at) }

  validates :start_at, presence: true
  validate :start_at_must_be_more_than_six_weeks_in_the_future, unless: :first_schedule?

  def end_at
    self[:end_at] - 1.day if self[:end_at]
  end

  def self.with_end_at
    select('*, LEAD(start_at) OVER (ORDER BY start_at) AS end_at')
  end

  def modifiable?
    start_at > 6.weeks.from_now
  end

  # TODO: EXTRACT METHODS HERE. DO NOT MERGE THIS
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.available_slots_by_day(from, to)
    available_slots_by_day = {}

    User.guiders.each do |guider|
      from.upto(to).each do |date|
        day_name = date.strftime('%A')
        available_slots_by_day[date] ||= []
        active_schedule = guider
                          .schedules
                          .order(:start_at)
                          .where('schedules.start_at < ?', date)
                          .last
        next unless active_schedule.present?

        available_slots = active_schedule
                          .slots
                          .where(day: day_name)

        available_slots.each do |available_slot|
          available_slots_by_day[date] << available_slot
        end
      end
    end

    available_slots_by_day.delete_if do |_, slots|
      slots.empty?
    end
  end

  def self.available_slots_with_guider_count(from, to)
    available_slots = []

    available_slots_by_day(from, to).each do |day, slots|
      slots_with_counts = {}
      slots.each do |slot|
        key = "#{slot.day} #{slot.start_at} #{slot.end_at}"

        hour, minute = slot.start_at.split(':').map(&:to_i)
        start_at = day.to_datetime.change(hour: hour, min: minute, sec: 0)

        hour, minute = slot.end_at.split(':').map(&:to_i)
        end_at = day.to_datetime.change(hour: hour, min: minute, sec: 0)

        slots_with_counts[key] ||= { guiders: 0, start: start_at, end: end_at }
        slots_with_counts[key][:guiders] += 1
      end
      available_slots << slots_with_counts.values
    end

    available_slots.flatten
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
