module Pages
  class RescheduleAppointment < SitePrism::Page
    set_url '/appointments/{id}/reschedule'
    element :start_at, '.t-start-at', visible: false
    element :end_at,   '.t-end-at', visible: false
    element :reschedule, '.t-reschedule'

    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )

    element :slot_unavailable_message, '.t-slot-unavailable-message'
  end
end
