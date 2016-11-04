module Pages
  class EditHoliday < SitePrism::Page
    set_url '/holidays/{ids*}/edit'
    element :delete, '.t-delete'
  end
end
