class BatchUpsertHolidays
  include ActiveModel::Model
  include DateRangePickerHelper
  extend ActiveModel::Naming

  attr_reader :title, :users, :all_day, :start_at, :end_at, :recur, :single_day_recur_end_at

  alias single_day_start_at start_at
  alias single_day_end_at end_at
  alias multi_day_start_at start_at
  alias multi_day_end_at end_at

  validates :title, presence: true
  validates :users, presence: true
  validate :end_at_comes_after_start_at
  validate :validate_recurrence_dates

  def initialize(options = {})
    @previous_holidays = options[:previous_holidays]
    @users   = options[:users]
    @title   = options[:title]
    @all_day = sanitise_boolean(options[:all_day])
    @recur   = sanitise_boolean(options[:recur])
    @single_day_recur_end_at = options.fetch(:single_day_recur_end_at) { Date.current }

    calculate_range(options)
  end

  def call
    return false unless valid?

    Holiday.where(id: @previous_holidays).destroy_all
    create_holidays
    true
  end

  private

  def sanitise_boolean(value)
    ActiveRecord::Type::Boolean.new.cast(value) || false
  end

  def calculate_range(options)
    @start_at = options[:start_at]
    @end_at = options[:end_at]

    return if @start_at.is_a?(ActiveSupport::TimeWithZone) && @end_at.is_a?(ActiveSupport::TimeWithZone)

    if all_day
      calculate_all_day_range(options)
    else
      calculate_one_day_range(options)
    end
  end

  def calculate_all_day_range(options)
    @start_at = strp_date_range_picker_date(options[:multi_day_start_at])
    @end_at   = strp_date_range_picker_date(options[:multi_day_end_at]).end_of_day
  end

  def calculate_one_day_range(options)
    date      = strp_date_range_picker_date(options[:single_day_start_at])
    @start_at = date.change(hour: options[:'single_day_start_at(4i)'], min: options[:'single_day_start_at(5i)'])
    @end_at   = date.change(hour: options[:'single_day_end_at(4i)'], min: options[:'single_day_end_at(5i)'])
  end

  def create_holidays
    ActiveRecord::Base.transaction do
      User.where(id: users).find_each do |user|
        recur ? create_holidays_for_user(user) : create_holiday_for_user(user)
      end
    end
  end

  def create_holidays_for_user(user) # rubocop:disable Metrics/AbcSize
    (start_at.to_date..single_day_recur_end_at.to_date).each do |day|
      next if day.on_weekend?

      starting = Time.utc(day.year, day.month, day.day, start_at.hour, start_at.min)
      ending   = Time.utc(day.year, day.month, day.day, end_at.hour, end_at.min)

      create_holiday_for_user(user, starting:, ending:)
    end
  end

  def create_holiday_for_user(user, starting: start_at, ending: end_at)
    Holiday.create!(
      title:,
      all_day:,
      bank_holiday: false,
      user:,
      start_at: starting,
      end_at: ending
    )
  end

  def end_at_comes_after_start_at
    return if end_at > start_at

    if all_day
      errors.add(:multi_day_end_at, 'must come after date from')
    else
      errors.add(:single_day_end_at, 'must come after start')
    end
  end

  def validate_recurrence_dates
    return unless recur
    return if single_day_recur_end_at > start_at

    errors.add(:single_day_recur_end_at, 'must come after start')
  end
end
