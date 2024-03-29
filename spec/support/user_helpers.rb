module UserHelpers
  def with_real_sso
    sso_env = ENV['GDS_SSO_MOCK_INVALID']
    ENV['GDS_SSO_MOCK_INVALID'] = '1'

    yield
  ensure
    ENV['GDS_SSO_MOCK_INVALID'] = sso_env
  end

  def current_user
    GDS::SSO.test_user
  end

  def given_a_browser_session_for(*users)
    users.each do |user|
      existing_session      = Capybara.session_name
      Capybara.session_name = user.to_param
      GDS::SSO.test_user    = user

      yield
    ensure
      Capybara.session_name = existing_session
    end
  end

  def given_the_user(type, organisation = :tpas)
    GDS::SSO.test_user = create(type, organisation)
    yield
  end

  def given_the_user_is_a_business_analyst(&block)
    given_the_user(:business_analyst, &block)
  end

  def given_the_user_is_an_administrator(&block)
    given_the_user(:administrator, &block)
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

  def given_the_user_is_a_guider(organisation: :tpas, &block)
    given_the_user(:guider, organisation, &block)
  end

  def given_the_user_is_a_resource_manager(organisation: :tpas, &block)
    given_the_user(:resource_manager, organisation, &block)
  end

  def given_the_user_is_an_agent(organisation: :tp, &block)
    given_the_user(:agent, organisation, &block)
  end

  def given_the_user_has_no_permissions(&block)
    given_the_user(:user, &block)
  end
end
