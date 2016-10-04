module Pages
  class NewAppointment < SitePrism::Page
    set_url '/appointments/new'

    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the contact_centre_agent permission for this app.'
    )
  end
end
