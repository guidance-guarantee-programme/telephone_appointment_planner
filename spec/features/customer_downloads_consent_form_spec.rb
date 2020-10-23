require 'rails_helper'

RSpec.feature 'Customer downloads generated consent form' do
  scenario 'Attempting to download from a missing appointment' do
    when_a_customer_attempts_to_download_from_a_missing_appointment
    then_they_see_a_404
  end

  scenario 'Attempting to download a missing attachment' do
    given_an_appointment_exists_without_an_attachment
    when_the_customer_attempts_to_download_the_attachment
    then_they_see_a_404
  end

  def given_an_appointment_exists_without_an_attachment
    @appointment = create(:appointment)
  end

  def when_the_customer_attempts_to_download_the_attachment
    visit appointment_consent_path(@appointment)
  end

  def when_a_customer_attempts_to_download_from_a_missing_appointment
    visit '/appointments/999/consent'
  end

  def then_they_see_a_404
    expect(page.status_code).to eq(404)
  end
end
