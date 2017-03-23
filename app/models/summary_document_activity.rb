class SummaryDocumentActivity < Activity
  validates :appointment, presence: true
  validate :can_create_summary

  private

  def can_create_summary
    return if appointment.nil? || appointment.can_create_summary?
    errors.add(:appointment, 'is in an invalid state')
  end

  def pusher_notify_user_ids
    [nil]
  end
end
