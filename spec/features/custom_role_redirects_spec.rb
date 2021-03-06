require 'rails_helper'

RSpec.feature 'Custom Role Redirects' do
  scenario 'Views the root path as a resource manager' do
    given_the_user_is_a_resource_manager do
      when_they_visit_the_home_page
      then_they_see_the_allocations_page
    end
  end

  scenario 'Views the root path as a guider' do
    given_the_user_is_a_guider do
      when_they_visit_the_home_page
      then_they_see_the_my_appointments_page
    end
  end

  scenario 'Views the root path as an agent' do
    given_the_user_is_an_agent do
      when_they_visit_the_home_page
      then_they_see_the_new_appointments_page
    end
  end
end

def when_they_visit_the_home_page
  @page = Pages::Home.new.tap(&:load)
end

def then_they_see_the_allocations_page
  expect(current_path).to eq allocations_path
end

def then_they_see_the_my_appointments_page
  expect(current_path).to eq my_appointments_path
end

def then_they_see_the_new_appointments_page
  expect(current_path).to eq new_appointment_path
end
