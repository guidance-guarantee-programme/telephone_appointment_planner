module Pages
  class NewHoliday < Base
    set_url '/holidays/new'

    element :title, '.t-title'
    elements :user_options, '.t-users option'
    element :save, '.t-save'
    element :multi_day, '.t-multi-day'
    element :recur, '.t-recur'
    element :recur_end_at, '.t-recur-end-at'

    section :multiple_day, Sections::MultipleDay, '.t-multi-day-container'
    section :single_day, Sections::SingleDay, '.t-single-day-container'

    def set_recur_end_at(date) # rubocop:disable Naming/AccessorMethodName
      recur_end_at.set I18n.l(date, format: :date_range_picker)
      execute_script '$(".daterangepicker").hide();'
    end

    def select_all_users
      user_options.map(&:select_option)
    end
  end
end
