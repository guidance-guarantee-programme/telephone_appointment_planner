class BatchUpsertHolidays
  include ActiveModel::Model
  include DateRangePickerHelper
  extend ActiveModel::Naming

  attr_reader :title
  attr_reader :users
  attr_reader :all_day
  attr_reader :start_at
  attr_reader :end_at

  alias single_day_start_at start_at
  alias single_day_end_at end_at
  alias multi_day_start_at start_at
  alias multi_day_end_at end_at

  validates :title, presence: true
  validates :users, presence: true
  validate :end_at_comes_after_start_at

  def initialize(options = {})
    @previous_holidays = options[:previous_holidays]
    @users = options[:users]

    @title = options[:title]
    @all_day = ActiveRecord::Type::Boolean.new.cast(options[:all_day]) || false

    calculate_range(options)
  end

  def to_model
    if Array(@previous_holidays).any?
      @model ||= Holiday.find(@previous_holidays.first)
    else
      Holiday.new
    end
  end

  def call
    return false unless valid?

    Holiday.where(id: @previous_holidays).destroy_all
    create_holidays
    true
  end

  private

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
      User.where(id: users).each do |user|
        create_holiday_for_user(user)
      end
    end
  end

  def create_holiday_for_user(user)
    Holiday.create!(
      title: title,
      all_day: all_day,
      bank_holiday: false,
      user: user,
      start_at: start_at,
      end_at: end_at
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
end
