class CompanyCalendarsController < ApplicationController
  before_action :authorise_for_guiders!
  store_previous_page_on :show
end
