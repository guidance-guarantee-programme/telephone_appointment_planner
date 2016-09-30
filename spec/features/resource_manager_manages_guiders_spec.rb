# rubocop:disable Metrics/AbcSize
require 'rails_helper'

RSpec.feature 'Resource manager manages guiders' do
  scenario 'Viewing and filtering by groups', js: true do
    given_the_user_is_a_resource_manager do
      and_there_are_guiders_assigned_to_groups
      when_they_visit_the_guiders_page
      then_they_see_all_the_guiders
      when_they_filter_by_a_specific_group
      then_they_see_only_those_guiders
    end
  end

  def and_there_are_guiders_assigned_to_groups
    @team_one = create(:group)
    @team_two = create(:group)
    @guider   = create(:guider) { |g| g.groups << @team_one }
    @other    = create(:guider) { |g| g.groups << @team_two }
  end

  def when_they_visit_the_guiders_page
    @page = Pages::ManageGuiders.new.tap(&:load)
  end

  def then_they_see_all_the_guiders
    expect(@page).to have_guiders(count: 2)
  end

  def when_they_filter_by_a_specific_group
    @page.search.set @team_one.name
  end

  def then_they_see_only_those_guiders
    # this will wait for the JS search to complete
    expect(@page).to have_text(@guider.name)
    expect(@page).to have_guiders(count: 1)

    @page.guiders.first.tap do |guider|
      expect(guider).to have_groups(count: 1)
      expect(guider.groups.first).to have_text(@team_one.name)
    end
  end
end
