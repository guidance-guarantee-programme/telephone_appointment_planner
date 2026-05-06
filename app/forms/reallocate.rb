class Reallocate
  include ActiveModel::Model

  attr_accessor :guider_id, :rescheduling_route

  validates :guider_id, presence: true
  validates :rescheduling_route, presence: true

  def initialize(appointment, current_user, params = {})
    @appointment = appointment
    @current_user = current_user

    super(params)
  end

  delegate :name, to: :appointment

  def update
    if valid?
      @appointment.update(guider_id:, rescheduling_route:, rescheduling_reason:)
    else
      false
    end
  end

  def model
    @appointment
  end

  def guider_options
    @current_user.colleagues.guiders.active.reorder(:name).pluck(:name, :id)
  end

  private

  attr_reader :appointment

  def rescheduling_reason
    Appointment::OFFICE_REALLOCATED
  end
end
