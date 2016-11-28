module Pages
  class SortGuiders < Base
    set_url '/users/sort'

    element :save, '.t-save'

    elements :guiders, '.t-guider'

    def reverse_guiders
      page.execute_script <<-JS
        $(".t-guider").each(function() {
          $(this).prependTo(this.parentNode);
        });

        $.publish('sortable-guiders-update');
      JS
    end
  end
end
