module UserHelpers
  def current_user
    GDS::SSO.test_user
  end

  def given_the_user_is_a_guider
    GDS::SSO.test_user = create(:guider)
    yield
  ensure
    GDS::SSO.test_user = nil
  end

  def given_the_user_is_a_resource_manager
    GDS::SSO.test_user = create(:resource_manager)
    yield
  ensure
    GDS::SSO.test_user = nil
  end

  def given_the_user_is_an_agent
    GDS::SSO.test_user = create(:agent)
    yield
  ensure
    GDS::SSO.test_user = nil
  end

  def given_the_user_has_no_permissions
    GDS::SSO.test_user = create(:user)
    yield
  ensure
    GDS::SSO.test_user = nil
  end
end
