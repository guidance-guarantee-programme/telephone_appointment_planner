module Pages
  class ManageGroups < SitePrism::Page
    set_url '/groups'

    element :affected, '.t-affected'
    element :group, '.t-group'
    element :add_group, '.t-add-group'
    element :flash_of_success, '.alert-success'
  end
end
