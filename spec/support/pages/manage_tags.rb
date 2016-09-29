module Pages
  class ManageGroups < SitePrism::Page
    set_url '/groups'

    elements :groups, '.t-group'
  end
end
