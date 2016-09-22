require 'rails_helper'

RSpec.feature "roles" do
  context "user without any permissions" do
    let :user do
      create(:user)
    end

    before do
      GDS::SSO.test_user = user
    end

    scenario "allows resource managers to manage resources" do
      visit "/"
      expect(page).to have_content "Sorry, you don't seem to have the resource_manager_permission permission for this app."
    end
  end

  context "resource manager" do
    let :user do
      create(:resource_manager_user)
    end

    before do
      GDS::SSO.test_user = user
    end

    scenario "allows resource managers to manage resources" do
      visit "/"
      expect(page).to have_content "Welcome"
    end
  end
end
