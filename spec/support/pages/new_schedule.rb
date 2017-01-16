module Pages
  class NewSchedule < Base
    set_url '/users/{user_id}/schedules/new'

    elements :events, '.fc-event'

    element :save, '.t-save'
    element :start_at, '.t-start-at'
    element :mid, '.t-mid'
  end
end
