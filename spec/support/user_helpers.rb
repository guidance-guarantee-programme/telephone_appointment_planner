module UserHelpers
  def current_user
    GDS::SSO.test_user
  end

  def given_a_browser_session_for(user)
    existing_session      = Capybara.session_name
    Capybara.session_name = user.to_param
    GDS::SSO.test_user    = user

    yield
  ensure
    Capybara.session_name = existing_session
    GDS::SSO.test_user    = nil
  end

  def given_the_user(type)
    GDS::SSO.test_user = create(type)
    yield
  ensure
    GDS::SSO.test_user = nil
  end

  def given_the_user_is_a_pension_wise_api_user(&block)
    given_the_user(:pension_wise_api_user, &block)
  end

  def given_the_user_is_a_contact_centre_team_leader(&block)
    given_the_user(:contact_centre_team_leader, &block)
  end

  def given_the_user_is_both_guider_and_manager(&block)
    given_the_user(:guider_and_resource_manager, &block)
  end

  def given_the_user_is_a_guider(&block)
    given_the_user(:guider, &block)
  end

  def given_the_user_is_a_resource_manager(&block)
    given_the_user(:resource_manager, &block)
  end

  def given_the_user_is_an_agent(&block)
    given_the_user(:agent, &block)
  end

  def given_the_user_has_no_permissions(&block)
    given_the_user(:user, &block)
  end
end
