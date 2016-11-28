module Pages
  class EditAppointment < Base
    set_url '/appointments/{id}/edit'

    element :flash_of_success, '.alert-success'
    element :guider,                                '.t-guider'
    element :date_time,                             '.t-appointment-date-time'
    element :created_date,                          '.t-created-date'
    element :first_name,                            '.t-first-name'
    element :last_name,                             '.t-last-name'
    element :email,                                 '.t-email'
    element :phone,                                 '.t-phone'
    element :mobile,                                '.t-mobile'
    element :memorable_word,                        '.t-memorable-word'
    element :notes,                                 '.t-notes'
    element :opt_out_of_market_research,            '.t-opt-out-of-market-research'
    element :status, '.t-status'
    element :submit, '.t-save'

    section :activity_feed, '.t-activity-feed' do
      elements :activities, '.t-activity'

      element :message, '.t-message'
      element :submit, '.t-submit-message'

      element :further_activities, '.t-further-activities'
      element :hidden_activities, '.t-hidden-activities'
    end

    section :breadcrumb, '.t-breadcrumb' do
      elements :links, 'a'
    end

    def breadcrumb_links
      breadcrumb.links.map do |link|
        { link.text => link['href'] }
      end
    end
  end
end
