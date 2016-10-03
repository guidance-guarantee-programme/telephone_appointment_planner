module Pages
  class NewSchedule < SitePrism::Page
    set_url '/users/{user_id}/schedules/new'

    elements :errors, '.field_with_errors'
    element :error_summary, '.t-errors'

    element :save, '.t-save'
    element :start_at, '.t-start-at'
  end
end
