module Pages
  class NewSchedule < Base
    set_url '/users/{user_id}/schedules/new'

    elements :events, '.fc-event'

    element :save, '.t-save'
    element :start_at, '.t-start-at'
    element :mid, '.t-mid'
    element :saturday, '.fc-sat'

    section :shift_modal, '.t-shift-modal' do
      element :monday, '.t-monday'
      element :tuesday, '.t-tuesday'
      element :wednesday, '.t-wednesday'
      element :thursday, '.t-thursday'
      element :friday, '.t-friday'
      element :save, '.t-save'
    end
  end
end
