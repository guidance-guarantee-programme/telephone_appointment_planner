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
    element :status, '.t-status'
    element :submit, '.t-save'
    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager, guider, or agent permission for this app.'
    )

    section :activity_feed, '.t-activity-feed' do
      elements :activities, '.t-activity'
      elements :dynamically_loaded_activities, '.t-dynamically-loaded-activity'

      element :message, '.t-message'
      element :submit, '.t-submit-message'

      element :further_activities, '.t-further-activities'
      element :hidden_activities, '.t-hidden-activities'
    end
  end
end
