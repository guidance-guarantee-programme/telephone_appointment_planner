require 'rails_helper'

RSpec.describe 'Sidekiq control panel' do
  scenario 'requires authentication' do
    with_real_sso do
      when_they_visit_the_sidekiq_panel
      they_are_required_to_authenticate
    end
  end

  scenario 'successfully authenticating' do
    given_the_user_is_a_resource_manager do
      when_they_visit_the_sidekiq_panel
      then_they_are_authenticated
    end
  end

  def when_they_visit_the_sidekiq_panel
    get '/sidekiq'
  end

  def they_are_required_to_authenticate
    expect(response).to be_server_error
  end

  def then_they_are_authenticated
    expect(response).to be_ok
  end
end
