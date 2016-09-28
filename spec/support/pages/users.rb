module Pages
  class Users < SitePrism::Page
    set_url '/users'
    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )
  end
end
