module Pages
  class Activities < SitePrism::Page
    set_url '/activities'

    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )

    elements :activities, '.t-activity'
  end
end
