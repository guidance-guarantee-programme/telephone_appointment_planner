module Pages
  class PreviewAppointment < Base
    set_url '/appointments/preview'

    element :road_safety_banner,  '.t-road-safety-banner'
    element :confirm_appointment, '.t-confirm-appointment'
    element :edit_appointment,    '.t-edit-appointment'
    element :preview,             '.t-preview'
  end
end
