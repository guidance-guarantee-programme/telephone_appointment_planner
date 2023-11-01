require 'rails_helper'

RSpec.describe 'PUT /auth/gds/api/users/:id' do
  scenario 'Signon pushing an existing, newly disabled user' do
    given_the_user_is_a_pension_wise_api_user do
      given_the_guider_exists
      and_the_guider_has_future_availability
      when_signon_pushes_their_disabled_account
      then_their_future_availability_is_nerfed
    end
  end

  def given_the_guider_exists
    @guider = create(:guider)
  end

  def and_the_guider_has_future_availability
    create(:bookable_slot, guider: @guider, start_at: 1.day.from_now)
  end

  def when_signon_pushes_their_disabled_account
    put "/auth/gds/api/users/#{@guider.uid}", params: {
      'user' => {
        'uid' => @guider.uid,
        'name' => 'Daisy Lovell',
        'email' => 'daisy@example.com',
        'permissions' => [],
        'organisation_slug' => 'cita',
        'organisation_content_id' => @guider.organisation_content_id,
        'disabled' => true
      }
    }, as: :json
  end

  def then_their_future_availability_is_nerfed
    @guider.reload

    expect(@guider.bookable_slots).to be_empty
    # ensure guider is inactive so no future schedules are generated
    expect(@guider).not_to be_active
  end
end
