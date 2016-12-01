module Pages
  class EditHoliday < Base
    set_url '/holidays/{ids*}/edit'

    element :title, '.t-title'
    elements :user_options, '.t-users option'
    element :save, '.t-save'
    element :delete, '.t-delete'
    element :multi_day, '.t-multi-day'

    section :multiple_day, Sections::MultipleDay, '.t-multi-day-container'
    section :single_day, Sections::SingleDay, '.t-single-day-container'

    def select_user(user)
      user_options.each do |user_option|
        user_option.select_option if user_option.value == user.id
      end
    end
  end
end
