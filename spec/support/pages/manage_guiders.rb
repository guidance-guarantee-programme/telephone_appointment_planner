module Pages
  class ManageGuiders < SitePrism::Page
    set_url '/users'

    element :search, '.t-search'

    sections :guiders, '.t-guider' do
      elements :groups, '.t-group'

      element :checkbox, '.t-checkbox'
    end

    section :action_panel, '.t-action-panel' do
      element :selected, '.t-selected'
      element :action, '.t-action'
      element :go, '.t-go'
    end
  end
end
