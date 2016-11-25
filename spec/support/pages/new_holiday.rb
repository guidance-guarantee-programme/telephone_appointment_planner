module Pages
  class NewHoliday < Base
    set_url '/holidays/new'

    element :title, '.t-title'
    element :date_range, '.t-date-range'
    elements :user_options, '.t-users option'
    element :save, '.t-save'

    def select_all_users
      user_options.map(&:select_option)
    end
  end
end
