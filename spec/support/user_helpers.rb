module UserHelpers
  def given_the_user_is_a_resource_manager
    GDS::SSO.test_user = create(:resource_manager)
    yield
  ensure
    GDS::SSO.test_user = nil
  end

  def given_the_user_is_a_contact_centre_agent
    GDS::SSO.test_user = create(:contact_centre_agent)
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
