class CreateHolidays
  include ActiveModel::Model
  extend ActiveModel::Naming

  attr_reader :title
  attr_reader :date_range
  attr_reader :users

  DATE_RANGE_PICKER_FORMAT = '%e/%m/%Y %H:%M'.freeze

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
      Time.zone.strptime(d, DATE_RANGE_PICKER_FORMAT)
    end
    User.where(id: users).each do |user|
      Holiday.create!(title: title, user: user, start_at: start_at, end_at: end_at)
    end
    true
  end
end
