module Pages
  class RescheduleAppointment < Base
    set_url '/appointments/{id}/reschedule'
    element :start_at, '.t-start-at', visible: false
    element :end_at,   '.t-end-at', visible: false
    element :reschedule, '.t-reschedule'
    element :slot_unavailable_message, '.t-slot-unavailable-message'
    element :client_rescheduled, '.t-client-rescheduled'
    element :pension_wise_rescheduled, '.t-pension-wise-rescheduled'
    element :via_phone, '.t-via-phone'
    element :via_email_or_crm, '.t-via-email-or-crm'

    element :availability_calendar_off, '.t-availability-calendar-off'
    element :availability_calendar_on, '.t-availability-calendar-on'
    element :guider, '.t-guider'
    element :ad_hoc_start_at, '.t-ad-hoc-start-at'
    element :internal_availability, '.t-internal-availability'
    element :reschedule, '.t-reschedule'
    elements :slots, '.fc-time-grid-event'
    elements :calendar_events, '.fc-event'
    element :next_period, '.fc-next-button'

    def ad_hoc_start_at(value)
      execute_script("$('.t-ad-hoc-start-at').val('#{value}')")
    end
  end
end
