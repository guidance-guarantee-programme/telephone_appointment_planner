module Pages
  class EditSchedule < SitePrism::Page
    set_url '/users/{user_id}/schedules/{id}/edit'
    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )
  end
end
