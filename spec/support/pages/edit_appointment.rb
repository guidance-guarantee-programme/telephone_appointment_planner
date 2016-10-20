module Pages
  class EditAppointment < SitePrism::Page
    set_url '/appointments/{id}/edit'

    element :first_name,                            '.t-first-name'
    element :last_name,                             '.t-last-name'
    element :email,                                 '.t-email'
    element :phone,                                 '.t-phone'
    element :mobile,                                '.t-mobile'
    element :memorable_word,                        '.t-memorable-word'
    element :notes,                                 '.t-notes'
    element :opt_out_of_market_research,            '.t-opt-out-of-market-research'
    element :where_did_you_hear_about_pension_wise, '.t-where-did-you-hear-about-pension-wise'
    element :who_is_your_pension_provider,          '.t-who-is-your-pension-provider'
    element :submit, '.t-save'
  end
end
