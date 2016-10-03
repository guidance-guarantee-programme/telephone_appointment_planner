class Schedule < ApplicationRecord
  belongs_to :user
  has_many :slots, inverse_of: :schedule, dependent: :destroy
  accepts_nested_attributes_for :slots, allow_destroy: true
  scope :by_from, -> { order(:from) }

  validates :from, presence: true
  validate :from_must_be_more_than_six_weeks_in_the_future

  def destroyable?
    from > 6.weeks.from_now
  end

  private

  def from_must_be_more_than_six_weeks_in_the_future
    too_soon = from && from < 6.weeks.from_now
    errors.add(:from, 'must be more than six weeks from now') if too_soon
  end
end
