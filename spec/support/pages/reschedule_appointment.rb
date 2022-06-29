module Pages
  class RescheduleAppointment < Base
    set_url '/appointments/{id}/reschedule'
    element :start_at, '.t-start-at', visible: false
    element :end_at,   '.t-end-at', visible: false
    element :reschedule, '.t-reschedule'
    element :slot_unavailable_message, '.t-slot-unavailable-message'

    element :availability_calendar_off, '.t-availability-calendar-off'
    element :availability_calendar_on, '.t-availability-calendar-on'
    element :guider, '.t-guider'
    element :ad_hoc_start_at, '.t-ad-hoc-start-at'
    element :all_availability, '.t-all-availability'
    elements :slots, '.fc-time-grid-event'
    elements :calendar_events, '.fc-event'

    def ad_hoc_start_at(value)
      execute_script("$('.t-ad-hoc-start-at').val('#{value}')")
    end
  end
end
