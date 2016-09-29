module Pages
  class EditSchedule < SitePrism::Page
    set_url '/users/{user_id}/schedules/{id}/edit'

    elements :errors, '.field_with_errors'
    element :error_summary, '.t-errors'

    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )

    element :save_button, '.t-save'
    element :from, '.t-from'
  end
end
