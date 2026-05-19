class Holiday < ApplicationRecord
  acts_as_copy_target

  DESCRIPTION_OPTIONS = {
    'annual_leave' => 'Annual Leave',
    'sick_leave' => 'Sick Leave',
    'medical_appointment' => 'Medical Appointment',
    'financial_wellbeing_day' => 'Financial Wellbeing Day',
    'maternity_leave' => 'Maternity Leave',
    'paternity_leave' => 'Paternity Leave',
    'neo-natal_leave' => 'Neo-natal Leave',
    'parental_leave' => 'Parental Leave',
    'carers_leave' => 'Carers Leave',
    'study_or_training_leave' => 'Study/Training Leave',
    'adoption_leave' => 'Adoption Leave',
    'time_off_for_dependents' => 'Time Off For Dependents',
    'compassionate_leave' => 'Compassionate Leave',
    'volunteering' => 'Volunteering',
    'civic_duties' => 'Civic Duties',
    'secondment' => 'Secondment',
    'training' => 'Training',
    'team_meeting' => 'Team Meeting',
    'conference' => 'Conference',
    'directorate_event' => 'Directorate Event',
    'all_organisation_event' => 'All Organisation Event',
    'overspill_management' => 'Overspill Management',
    'extended_duration_appointment' => 'Extended Duration Appointment',
    'other' => 'Other'
  }.freeze

  belongs_to :user, optional: true
  belongs_to :creator, class_name: 'User'

  validates :user, presence: true, unless: :bank_holiday?
  validates :all_day, inclusion: [true, false]
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :description, inclusion: { in: DESCRIPTION_OPTIONS.keys }
  validates :additional_information, length: { maximum: 300 }

  def self.merged_for_calendar_view(start_at, end_at, user) # rubocop:disable Metrics/MethodLength
    select(
      <<-SQL
        DISTINCT ON(holidays.bank_holiday, holidays.all_day, holidays.start_at, holidays.end_at, holidays.title)
        holidays.bank_holiday, holidays.all_day, holidays.title, holidays.start_at, holidays.end_at,
        string_agg(holidays.id::text, ',') as holiday_ids
      SQL
    )
      .joins('LEFT JOIN users ON users.id = holidays.user_id')
      .where(users: { organisation_content_id: [user.organisation_content_id, nil] })
      .where('(holidays.start_at, holidays.end_at) OVERLAPS (?, ?)', start_at, end_at)
      .group(:bank_holiday, :all_day, :start_at, :end_at, :title)
      .order(:start_at)
  end

  def self.scoped_for_user_including_bank_holidays(user)
    where('(user_id = ? OR bank_holiday = true)', user.id)
  end

  def self.overlapping_or_inside(start_at, end_at, user)
    includes(:user)
      .where(users: { organisation_content_id: [user.organisation_content_id, nil] })
      .where('(holidays.start_at, holidays.end_at) OVERLAPS (?, ?)', start_at, end_at)
      .where.not("holidays.title ilike 'HIDE%'")
  end

  def holiday_ids
    attributes['holiday_ids']
  end
end
