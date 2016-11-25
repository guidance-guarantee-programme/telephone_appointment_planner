module Pages
  class EditHoliday < Base
    set_url '/holidays/{ids*}/edit'
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
  end
end
