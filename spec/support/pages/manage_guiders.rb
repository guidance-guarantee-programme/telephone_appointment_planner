module Pages
  class ManageGuiders < Base
    set_url '/users'

    element :flash_of_success, '.alert-success'

    element :search, '.t-search'

    sections :guiders, '.t-guider' do
      element :active_icon, '.t-active-icon'
      elements :groups, '.t-group'

      element :checkbox, '.t-checkbox'
    end

    element :deactivate, '.t-deactivate'
    element :activate, '.t-activate'

    section :action_panel, '.t-action-panel' do
      element :selected, '.t-selected'
      element :action, '.t-action'
      element :go, '.t-go'
    end
  end
end
