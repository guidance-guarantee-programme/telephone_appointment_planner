class ReissueSummary
  include ActiveModel::Model

  attr_accessor :current_user, :appointment, :email

  validates :email, presence: true

  def reissue
    unless valid? && SummaryDocumentApi.new.reissue_digital_summary(appointment.id, email, current_user)
      errors.add(:email, 'could not be reissued')

      return false
    end

    true
  end

  def email
    @email || summarised_email
  end

  def can_reissue?
    summarised_email.present?
  end

  private

  def summarised_email
    @summarised_email ||= SummaryDocumentApi.new.digital_summary_email(appointment.id)
  end
end
