module Pages
  class EditUser < SitePrism::Page
    set_url '/users/{id}/edit'
    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )
    element :flash_of_success, '.alert-success'

    sections :schedules, '.t-schedule' do
      element :delete, '.t-delete'
      element :edit, '.t-edit'
    end
  end
end
