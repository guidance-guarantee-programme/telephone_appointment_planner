module Pages
  class EditSchedule < Base
    set_url '/users/{user_id}/schedules/{id}/edit'

    elements :events, '.fc-event'

    element :save, '.t-save'
    element :start_at, '.t-start-at'
  end
end
