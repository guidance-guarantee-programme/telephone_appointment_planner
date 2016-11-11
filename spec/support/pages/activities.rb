module Pages
  class Activities < SitePrism::Page
    set_url '/activities'

    element(
      :permission_error_message,
      'h1',
      text: /Sorry, you don\'t seem to have the \w+ permission for this app./
    )

    elements :activities, '.t-activity'
  end
end
