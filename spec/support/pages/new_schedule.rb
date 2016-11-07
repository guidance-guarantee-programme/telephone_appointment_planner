module Pages
  class NewSchedule < SitePrism::Page
    set_url '/users/{user_id}/schedules/new'

    elements :events, '.fc-event'

    element :save, '.t-save'
    element :start_at, '.t-start-at'
  end
end
