class BookableSlotReport
  include ActiveModel::Model
  include Report

  attr_reader :date_range, :current_user

  validates :date_range, presence: true

  def initialize(params = {})
    @date_range = params[:date_range]
    @current_user = params[:current_user]
  end

  def generate
    BookableSlot
      .select("to_char(bookable_slots.created_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS created_at")
      .select('guiders.name AS guider')
      .select("to_char(bookable_slots.start_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS start_at")
      .select("to_char(bookable_slots.end_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS end_at")
      .joins('INNER JOIN users guiders ON guiders.id = bookable_slots.guider_id')
      .where('guiders.organisation_content_id = ?', current_user.organisation_content_id)
      .where('bookable_slots.start_at >= ? AND bookable_slots.start_at <= ?', range.begin, range.end.end_of_day)
      .where(schedule_type: 'pension_wise')
      .order(start_at: :desc)
  end

  def file_name
    "slots-report-#{range_title}.csv"
  end
end
