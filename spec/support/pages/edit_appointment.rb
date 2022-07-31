module Pages
  class EditAppointment < Base
    set_url '/appointments/{id}/edit'

    element :flash_of_success,                      '.alert-success'
    element :flash_of_danger,                       '.alert-danger'
    element :dc_pot_unsure_banner,                  '.t-dc-pot-unsure'
    element :appointment_was_imported_message,      '.t-appointment-was-imported-message'
    element :third_party_booked_banner,             '.t-third-party-booked'
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
    element :secondary_status, '.t-secondary-status'
    elements :secondary_status_options, '.t-secondary-status > option:not(:empty)'
    element :submit, '.t-save'
    element :rebook, '.t-rebook'
    element :process, '.t-process'
    element :resend_email_confirmation, '.t-resend-email-confirmation'
    element :reschedule, '.t-reschedule'
    element :reissue_summary, '.t-reissue-summary'

    element :third_party_booked,                    '.t-third-party-booked'
    element :data_subject_name,                     '.t-data-subject-name'
    element :data_subject_date_of_birth_day,        '.t-data-subject-date-of-birth-day'
    element :data_subject_date_of_birth_month,      '.t-data-subject-date-of-birth-month'
    element :data_subject_date_of_birth_year,       '.t-data-subject-date-of-birth-year'
    element :data_subject_consent_obtained,         '.t-data-subject-consent-obtained'
    element :data_subject_consent_evidence,         '.t-data-subject-consent-evidence'
    element :consent_download,                      '.t-consent-download'
    element :power_of_attorney,                     '.t-power-of-attorney'
    element :power_of_attorney_evidence,            '.t-power-of-attorney-evidence'
    element :power_of_attorney_download,            '.t-power-of-attorney-download'
    element :printed_consent_form_required,         '.t-printed-consent-form-required'
    element :printed_consent_form_postcode_lookup,  '.t-printed-consent-form-postcode-lookup'

    element :permissions_warning, '.t-permissions'

    section :activity_feed, '.t-activity-feed' do
      elements :activities, '.t-activity'

      element :message, '.t-message'
      element :submit, '.t-submit-message'

      element :further_activities, '.t-further-activities'
      element :audit_activity, '.t-audit-activity'
      element :hidden_activity, '.t-hidden-activity'
      elements :high_priority_activities, '.t-high-priority-activity'
      element :resolved_activities, '.t-resolved-activity'
      element :unresolved_activities, '.t-unresolved-activity'
      element :resolve_activity_button, '.t-resolve-activity'
      element :more_activity_link, '.t-activity-more'
    end

    section :reissue_modal, '.t-reissue-modal' do
      element :errors, '.t-errors'
      element :email, '.t-email'
      element :save, '.t-save'
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
