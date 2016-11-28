module Pages
  class EditHoliday < Base
    set_url '/holidays/{ids*}/edit'

    element :all_day_date_range, '.t-all-day-date-range'
    element :one_day_date_range, '.t-one-day-date-range'
    element :title, '.t-title'
    element :date_range, '.t-date-range'
    elements :user_options, '.t-users option'
    element :save, '.t-save'
    element :delete, '.t-delete'

    def select_user(user)
      user_options.each do |user_option|
        user_option.select_option if user_option.value == user.id
      end
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
