module Pages
  class Users < SitePrism::Page
    set_url '/users'
    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )
  end
end
