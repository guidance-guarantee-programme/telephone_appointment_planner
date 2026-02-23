module Pages
  class ReallocateAppointment < Base
    set_url '/appointments/{id}/reallocate/new'

    element :guider, '.t-guider'
    element :reallocate, '.t-reallocate'
  end
end
