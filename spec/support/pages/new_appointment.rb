module Pages
  class NewAppointment < SitePrism::Page
    set_url '/appointments/new'

    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the agent permission for this app.'
    )

    element :first_name,                            '.t-first-name'
    element :last_name,                             '.t-last-name'
    element :email,                                 '.t-email'
    element :phone,                                 '.t-phone'
    element :mobile,                                '.t-mobile'
    element :year_of_birth,                         '.t-year-of-birth'
    element :memorable_word,                        '.t-memorable-word'
    element :notes,                                 '.t-notes'
    element :opt_out_of_market_research,            '.t-opt-out-of-market-research'
    element :where_did_you_hear_about_pension_wise, '.t-where-did-you-hear-about-pension-wise'
    element :start_at,                              '.t-start-at'
    element :end_at,                                '.t-end-at'
    element :save,                                  '.t-save'
  end
end
