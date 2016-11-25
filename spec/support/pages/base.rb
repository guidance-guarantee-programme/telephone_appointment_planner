module Pages
  class Base < SitePrism::Page
    element :permission_error_message, 'h1', text: /Sorry/
  end
end
