class CreateHolidays
  include ActiveModel::Model
  extend ActiveModel::Naming
  include DateRangePickerHelper

  attr_reader :title
  attr_reader :date_range
  attr_reader :users

  validates :title, presence: true
  validates :date_range, presence: true
  validates :users, presence: true

  def to_model
    Holiday.new
  end

  def initialize(title = nil, date_range = nil, users = [])
    @title = title
    @date_range = date_range
    @users = users
  end

  def call
    return false unless valid?
    start_at, end_at = date_range.split(' - ').map do |d|
      strp_date_range_picker_time(d)
    end

    ActiveRecord::Base.transaction do
      ranges = (start_at.to_date..end_at.to_date).map do |current|
        OpenStruct.new(
          start_at: current.beginning_of_day,
          end_at: current.end_of_day,
          all_day: true
        )
      end

      ranges[0].start_at = ranges[0].start_at.change(hour: start_at.hour, min: start_at.min)
      ranges[0].all_day = false
      ranges[-1].end_at = ranges[-1].end_at.change(hour: end_at.hour, min: end_at.min)
      ranges[-1].all_day = false

      User.where(id: users).each do |user|
        ranges.each do |range|
          Holiday.create!(
            title: title,
            user: user,
            bank_holiday: false,
            all_day: range.all_day,
            start_at: range.start_at,
            end_at: range.end_at,
          )
        end
      end
    end
    true
  end
end
