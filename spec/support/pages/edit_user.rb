module Pages
  class EditUser < SitePrism::Page
    set_url '/users/{id}/edit'
    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )
    element :flash_of_success, '.alert-success'

    sections :schedules, '.t-schedule' do
      element :delete, '.t-delete'
      element :edit, '.t-edit'
    end
  end
end
