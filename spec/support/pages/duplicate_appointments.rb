module Pages
  class DuplicateAppointments < Base
    set_url '/appointments/{id}/duplicates'

    elements :duplicates, '.t-duplicate'
  end
end
