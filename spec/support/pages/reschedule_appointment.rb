module Pages
  class RescheduleAppointment < Base
    set_url '/appointments/{id}/reschedule'
    element :start_at, '.t-start-at', visible: false
    element :end_at,   '.t-end-at', visible: false
    element :reschedule, '.t-reschedule'
    element :slot_unavailable_message, '.t-slot-unavailable-message'
  end
end
