module Pages
  class SortGuiders < SitePrism::Page
    set_url '/users/sort'

    element(
      :permission_error_message,
      'h1',
      text: /Sorry, you don\'t seem to have the \w+ permission for this app./
    )

    element :save, '.t-save'

    elements :guiders, '.t-guider'

    def reverse_guiders
      page.execute_script <<-JS
        $(".t-guider").each(function() {
          $(this).prependTo(this.parentNode);
        });
      JS
    end
  end
end
