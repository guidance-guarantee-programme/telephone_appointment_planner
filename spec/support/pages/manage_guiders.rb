module Pages
  class ManageGuiders < SitePrism::Page
    set_url '/users'

    element :search, '.t-search'

    sections :guiders, '.t-guider' do
      elements :groups, '.t-group'
    end
  end
end
