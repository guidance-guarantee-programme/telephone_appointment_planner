module Pages
  class ManageGroups < Base
    set_url '/groups'

    element :affected, '.t-affected'
    element :group, '.t-name'
    element :add_group, '.t-add-group'
    element :flash_of_success, '.alert-success'

    sections :groups, '.t-group' do
      element :remove, '.t-remove'
    end
  end
end
