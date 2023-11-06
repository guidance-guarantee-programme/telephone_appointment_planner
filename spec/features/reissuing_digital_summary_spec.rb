require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Reissuing summary documents digitally' do
  scenario 'A non-digitally summarised appointment' do
    given_the_user_is_a_resource_manager do
      and_a_postal_summarised_appointment_exists
      when_they_attempt_to_reissue_the_summary
      then_the_feature_is_hidden
    end
  end

  scenario 'A digitally summarised appointment', js: true do
    VCR.use_cassette(:digital_summary_reissuing) do
      given_the_user_is_a_resource_manager do
        and_a_digitally_summarised_appointment_exists
        when_they_attempt_to_reissue_the_summary
        then_they_see_the_previously_summarised_email
        when_they_alter_the_email_in_error
        then_they_see_the_errors
        when_they_provide_a_valid_email
        then_the_summary_is_reissued
      end
    end
  end

  def and_a_digitally_summarised_appointment_exists
    @appointment = create(:appointment, :digital_summarised, id: 1)
  end

  def and_a_postal_summarised_appointment_exists
    @appointment = create(:appointment, :postal_summarised, id: 1)
  end

  def when_they_attempt_to_reissue_the_summary
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def then_the_feature_is_hidden
    expect(@page).to have_no_reissue_summary
  end

  def then_they_see_the_previously_summarised_email
    @page.reissue_summary.click
    @page.wait_until_reissue_modal_visible

    expect(@page.reissue_modal.email.value).to eq('janet@example.com')
  end

  def when_they_alter_the_email_in_error
    @page.reissue_modal.email.set('wo@wo')
    @page.reissue_modal.save.click
  end

  def then_they_see_the_errors
    expect(@page.reissue_modal).to have_errors
  end

  def when_they_provide_a_valid_email
    @page.reissue_modal.email.set('bill@example.com')
    @page.reissue_modal.save.click
  end

  def then_the_summary_is_reissued
    @page.wait_until_reissue_modal_invisible
  end
end
# rubocop:enable Metrics/BlockLength
