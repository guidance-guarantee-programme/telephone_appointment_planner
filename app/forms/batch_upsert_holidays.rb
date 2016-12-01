class BatchUpsertHolidays
  include ActiveModel::Model
  include DateRangePickerHelper
  extend ActiveModel::Naming

  attr_reader :title
  attr_reader :date_range
  attr_reader :users
  attr_reader :all_day

  validates :title, presence: true
  validates :date_range, presence: true
  validates :users, presence: true

  def initialize(previous_holidays: [], title: nil, all_day: true, date_range: nil, users: [])
    @previous_holidays = previous_holidays
    @title = title
    @all_day = ActiveRecord::Type::Boolean.new.cast(all_day)
    @date_range = date_range
    @users = users
  end

  def to_model
    if @previous_holidays.any?
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

  def calculate_date_range
    parts = date_range.split(' - ')

    if all_day
      parts.map { |d| strp_date_range_picker_date(d) }
    else
      parts.map { |d| strp_date_range_picker_time(d) }
    end
  end

  def create_holidays
    start_at, end_at = calculate_date_range
    ActiveRecord::Base.transaction do
      User.where(id: users).each do |user|
        create_holiday_for_user(user, start_at, end_at)
      end
    end
  end

  def create_holiday_for_user(user, start_at, end_at)
    Holiday.create!(
      title: title,
      all_day: all_day,
      bank_holiday: false,
      user: user,
      start_at: start_at,
      end_at: end_at
    )
  end
end
