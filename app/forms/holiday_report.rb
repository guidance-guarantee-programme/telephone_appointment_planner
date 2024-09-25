class HolidayReport
  include ActiveModel::Model
  include Report

  attr_reader :date_range, :current_user

  validates :date_range, presence: true

  def initialize(params = {})
    @date_range = params[:date_range]
    @current_user = params[:current_user]
  end

  def generate # rubocop:disable Metrics/MethodLength
    Holiday
      .select("to_char(holidays.created_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS created_at")
      .select('holidays.title')
      .select('guiders.name AS guider')
      .select("to_char(holidays.start_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS start_at")
      .select("to_char(holidays.end_at::TIMESTAMPTZ, 'yyyy-MM-dd HH24:MI:ss TZ') AS end_at")
      .select("case when all_day = true then 'True' else 'False' end as all_day")
      .joins('INNER JOIN users guiders ON guiders.id = holidays.user_id')
      .where('guiders.organisation_content_id = ?', current_user.organisation_content_id)
      .where('holidays.start_at >= ? AND holidays.start_at <= ?', range.begin, range.end.end_of_day)
      .order(start_at: :desc)
  end

  def file_name
    "holidays-report-#{range_title}.csv"
  end
end
