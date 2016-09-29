require 'rails_helper'

RSpec.feature 'Resource manager manages groups', js: true do
  scenario 'Viewing existing groups' do
    given_the_user_identifies_as_a_resource_manager do
      and_there_are_existing_groups
      when_they_visit_the_groups_page
      then_they_see_the_groups
    end
  end

  scenario 'Deleting a group' do
    given_the_user_identifies_as_a_resource_manager do
      and_there_are_existing_groups
      when_they_visit_the_groups_page
      and_they_delete_a_group
      then_the_group_is_deleted
    end
  end

  def given_the_user_identifies_as_a_resource_manager
    @user = create(:resource_manager)
    GDS::SSO.test_user = @user

    yield
  ensure
    GDS::SSO.test_user = nil
  end

  def and_there_are_existing_groups
    @group = create(:group)
  end

  def when_they_visit_the_groups_page
    @page = Pages::ManageGroups.new.tap(&:load)
  end

  def then_they_see_the_groups
    expect(@page).to have_groups(count: 1)
  end

  def and_they_delete_a_group
    @page.groups.first.delete.click
  end

  def then_the_group_is_deleted
    expect(@page).to have_no_groups
  end
end
