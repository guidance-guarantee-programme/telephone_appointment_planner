module Pages
  class NewAppointmentAttempt < SitePrism::Page
    set_url '/appointment_attempts/new'

    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the agent permission for this app.'
    )
    element :ineligible_message,       '.t-ineligible-message'

    element :first_name,               '.t-first-name'
    element :last_name,                '.t-last-name'
    element :date_of_birth,            '.t-date-of-birth'
    element :defined_contribution_pot, '.t-defined-contribution-pot'
    element :next,                     '.t-next'
  end
end
