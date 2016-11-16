require 'rails_helper'

RSpec.feature 'Resource manager sorts guiders' do
  scenario 'Resource manager sorts guiders', js: true do
    given_the_user_is_a_resource_manager do
      and_there_are_some_guiders
      when_they_sort_those_guiders
      then_the_guiders_are_in_the_new_order
    end
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
    expect(@page.guiders.map(&:text)).to eq @guiders.reverse.map(&:name)
  end
end
