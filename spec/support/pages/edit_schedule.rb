module Pages
  class EditSchedule < SitePrism::Page
    set_url '/users/{user_id}/schedules/{id}/edit'

    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )

    elements :events, '.fc-event'

    element :save, '.t-save'
    element :start_at, '.t-start-at'
  end
end
