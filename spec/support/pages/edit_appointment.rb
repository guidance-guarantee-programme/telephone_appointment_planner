module Pages
  class EditAppointment < Base
    set_url '/appointments/{id}/edit'

    element :flash_of_success,                      '.alert-success'
    element :flash_of_danger,                       '.alert-danger'
    element :dc_pot_unsure_banner,                  '.t-dc-pot-unsure'
    element :appointment_was_imported_message,      '.t-appointment-was-imported-message'
    element :third_party_booked_banner,             '.t-third-party-booked'
    element :due_diligence_banner,                  '.t-due-diligence-banner'
    element :guider,                                '.t-guider'
    element :date_time,                             '.t-appointment-date-time'
    element :date_of_birth_day,                     '.t-date-of-birth-day'
    element :date_of_birth_month,                   '.t-date-of-birth-month'
    element :date_of_birth_year,                    '.t-date-of-birth-year'
    element :eligibility_reason,                    '.t-eligibility-reason'
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
    element :cancelled_via_phone,                   '.t-cancelled-via-phone'
    element :cancelled_via_email,                   '.t-cancelled-via-email'
    element :country_code,                          '.t-country-of-residence'
    element :ms_teams_call,                         '.t-ms-teams-call'

    element :status, '.t-status'
    element :secondary_status, '.t-secondary-status'
    elements :secondary_status_options, '.t-secondary-status > option:not(:empty)'
    element :submit, '.t-save'
    element :rebook, '.t-rebook'
    element :process, '.t-process'
    element :resend_email_confirmation, '.t-resend-email-confirmation'
    element :resend_print_confirmation, '.t-resend-print-confirmation'
    element :reschedule, '.t-reschedule'
    element :reallocate, '.t-reallocate'

    element :third_party_booked,                    '.t-third-party-booked'
    element :data_subject_name,                     '.t-data-subject-name'
    element :data_subject_date_of_birth_day,        '.t-data-subject-date-of-birth-day'
    element :data_subject_date_of_birth_month,      '.t-data-subject-date-of-birth-month'
    element :data_subject_date_of_birth_year,       '.t-data-subject-date-of-birth-year'

    element :permissions_warning, '.t-permissions'
    element :scheduled_today_banner, '.t-today'
    element :scheduled_another_day_banner, '.t-not-today'

    section :activity_feed, '.t-activity-feed' do
      elements :activities, '.t-activity'

      element :message, '.t-message'
      element :submit, '.t-submit-message'

      element :further_activities, '.t-further-activities'
      elements :audit_activities, '.t-audit-activity'
      element :hidden_activity, '.t-hidden-activity'
      elements :high_priority_activities, '.t-high-priority-activity'
      element :resolved_activities, '.t-resolved-activity'
      element :unresolved_activities, '.t-unresolved-activity'
      element :resolve_activity_button, '.t-resolve-activity'
    end

    element :disability_yes, '.t-disability-yes'
    element :disability_no, '.t-disability-no'
    element :mental_health_condition_yes, '.t-mental-health-condition-yes'
    element :mental_health_condition_no, '.t-mental-health-condition-no'
    element :vulnerable_customer_yes, '.t-vulnerable-customer-yes'
    element :vulnerable_customer_no, '.t-vulnerable-customer-no'
    element :falling_into_financial_difficulties, '.t-falling-into-financial-difficulties'
    element :separating_or_getting_divorced, '.t-separating-or-getting-divorced'
    element :being_diagnosed_with_a_health_condition, '.t-being-diagnosed-with-a-health-condition'
    element :dealing_with_bereavement, '.t-dealing-with-bereavement'
    element :starting_changing_or_losing_a_job, '.t-starting-changing-or-losing-a-job'
    element :approaching_later_life, '.t-approaching-later-life'
    element :moving_or_losing_a_home, '.t-moving-or-losing-a-home'
    element :partially_or_fully_retiring, '.t-partially-or-fully-retiring'
    element :getting_married_or_becoming_civil_partners, '.t-getting-married-or-becoming-civil-partners'

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
