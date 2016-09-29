module Pages
  class ManageGroups < SitePrism::Page
    set_url '/groups'

    sections :groups, '.t-group' do
      element :delete, '.t-delete'
    end
  end
end
