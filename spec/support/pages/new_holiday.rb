module Pages
  class NewHoliday < Base
    set_url '/holidays/new'

    element :title, '.t-title'
    elements :user_options, '.t-users option'
    element :save, '.t-save'
    element :multi_day, '.t-multi-day'

    section :multiple_day, Sections::MultipleDay, '.t-multi-day-container'
    section :single_day, Sections::SingleDay, '.t-single-day-container'

    def select_all_users
      user_options.map(&:select_option)
    end
  end
end
