module Pages
  class EditUser < Base
    set_url '/users/{id}/edit'

    element :flash_of_success, '.alert-success'

    sections :schedules, '.t-schedule' do
      element :delete, '.t-delete'
      element :edit, '.t-edit'
    end
  end
end
