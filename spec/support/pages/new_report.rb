module Pages
  class NewReport < SitePrism::Page
    set_url '/reports/new'

    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )

    section :appointment_report, '.t-appointment-report' do
      element :where,     '.t-where'
      element :is_within, '.t-is-within'
      element :download,  '.t-download'
    end

    section :utilisation_report, '.t-utilisation-report' do
      element :is_within, '.t-is-within'
      element :download,  '.t-download'
    end
  end
end
