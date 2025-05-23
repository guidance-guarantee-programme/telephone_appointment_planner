require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager sorts guiders' do
  scenario 'Resource manager sorts guiders', js: true do
    given_the_user_is_a_resource_manager do
      and_there_are_some_guiders
      and_there_is_a_deactivated_guider
      when_they_sort_those_guiders
      then_the_guiders_are_in_the_new_order
    end
  end

  def and_there_is_a_deactivated_guider
    create(:deactivated_guider)
  end

  def and_there_are_some_guiders
    @guiders = [
      create(:guider, name: 'A'),
      create(:guider, name: 'B'),
      create(:guider, name: 'C')
    ]
  end

  def when_they_sort_those_guiders
    @page = Pages::SortGuiders.new.tap(&:load)
    @page.reverse_guiders
    @page.save.click
  end

  def then_the_guiders_are_in_the_new_order
    @page = Pages::SortGuiders.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success
    expect(@page.guiders.map(&:text)).to eq %w[C B A]
  end
end
# rubocop:enable Metrics/BlockLength
