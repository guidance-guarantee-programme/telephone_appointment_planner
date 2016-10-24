module Pages
  class ResourceCalendar < SitePrism::Page
    set_url '/resource_calendar'

    elements :guiders, '.fc-resource-cell'
  end
end
