class CreateHolidays
  include ActiveModel::Model
  extend ActiveModel::Naming

  attr_reader :title
  attr_reader :date_range
  attr_reader :user_ids

  DATE_RANGE_PICKER_FORMAT = '%e/%m/%Y %l:%M %p'.freeze

  validates :title, presence: true
  validates :date_range, presence: true
  validates :user_ids, presence: true

  def to_model
    Holiday.new
  end

  def initialize(params = {})
    @title = params[:title]
    @date_range = params[:date_range]
    @user_ids = Array(params[:user_ids]).map(&:to_i)
  end

  def call
    return false unless valid?
    users = User.find(user_ids)
    start_at, end_at = date_range.split(' - ').map do |d|
      Time.zone.strptime(d, DATE_RANGE_PICKER_FORMAT)
    end
    users.each do |user|
      Holiday.create!(title: title, user: user, start_at: start_at, end_at: end_at)
    end
    true
  end

  private

  def users
    User.find(user_ids)
  end
end
