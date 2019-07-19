module Pages
  class EditAppointment < Base
    set_url '/appointments/{id}/edit'

    element :flash_of_success,                      '.alert-success'
    element :appointment_was_imported_message,      '.t-appointment-was-imported-message'
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
    element :gdpr_consent_yes,                      '.t-gdpr-consent-yes'
    element :gdpr_consent_no,                       '.t-gdpr-consent-no'
    element :gdpr_consent_no_response,              '.t-gdpr-consent-no-response'

    element :status, '.t-status'
    element :submit, '.t-save'
    element :rebook, '.t-rebook'

    element :permissions_warning, '.t-permissions'

    section :activity_feed, '.t-activity-feed' do
      elements :activities, '.t-activity'

      element :message, '.t-message'
      element :submit, '.t-submit-message'

      element :further_activities, '.t-further-activities'
      element :audit_activity, '.t-audit-activity'
      element :hidden_activity, '.t-hidden-activity'
      element :high_priority_activities, '.t-high-priority-activity'
      element :resolved_activities, '.t-resolved-activity'
      element :unresolved_activities, '.t-unresolved-activity'
      element :resolve_activity_button, '.t-resolve-activity'
      element :more_activity_link, '.t-activity-more'
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
