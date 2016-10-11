module Pages
  class NewSchedule < SitePrism::Page
    set_url '/users/{user_id}/schedules/new'

    element :save, '.t-save'
    element :start_at, '.t-start-at'
  end
end
