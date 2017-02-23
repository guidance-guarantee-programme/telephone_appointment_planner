require 'rails_helper'

RSpec.describe 'POST /api/v1/appointments/:id/dropped_summary_documents' do
  scenario 'Successfully created a dropped summary document activity' do
    given_the_user_is_a_pension_wise_api_user do
      and_a_completed_appointment_exists
      when_the_client_posts_a_dropped_summary_document_notification
      then_the_service_responds_with_a_201
      and_the_activity_is_created
    end
  end

  def and_a_completed_appointment_exists
    @appointment = create(:appointment, status: :complete)
  end

  def when_the_client_posts_a_dropped_summary_document_notification
    post api_v1_appointment_dropped_summary_documents_path(@appointment), as: :json
  end

  def then_the_service_responds_with_a_201
    expect(response).to be_created
  end

  def and_the_activity_is_created
    DroppedSummaryDocumentActivity.first.tap do |activity|
      expect(activity).to have_attributes(
        appointment: @appointment,
        owner: @appointment.guider
      )
    end
  end
end
