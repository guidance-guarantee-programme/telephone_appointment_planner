module Pages
  class NewHoliday < Base
    set_url '/holidays/new'

    element :all_day_date_range, '.t-all-day-date-range'
    element :one_day_date_range, '.t-one-day-date-range'
    element :title, '.t-title'
    elements :user_options, '.t-users option'
    element :save, '.t-save'
    element :create_a_multiple_day_holiday, '.t-create-a-multiple-day-holiday'
    element :create_a_single_day_holiday, '.t-create-a-single-day-holiday'

    def select_all_users
      user_options.map(&:select_option)
    end

    def set_all_day_date_range(start_at, end_at)
      start_at = I18n.l(start_at, format: :date_range_picker)
      end_at = I18n.l(end_at, format: :date_range_picker)
      all_day_date_range.set "#{start_at} - #{end_at}"
      hide_date_range_picker
    end

    def set_one_day_date_range(start_at, end_at)
      start_at = I18n.l(start_at, format: :date_range_picker)
      end_at = I18n.l(end_at, format: :date_range_picker)
      one_day_date_range.set "#{start_at} - #{end_at}"
      hide_date_range_picker
    end

    private

    def hide_date_range_picker
      execute_script '$(".daterangepicker").hide();'
    end
  end
end
