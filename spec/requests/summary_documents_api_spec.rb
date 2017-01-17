require 'rails_helper'

RSpec.describe 'POST /api/v1/summary_documents' do
  scenario 'create a valid summary document activity' do
    given_the_user_is_a_pension_wise_api_user do
      and_a_completed_appointment_exists
      when_the_client_posts_a_valid_summary_document_request
      then_the_service_responds_with_a_201
      and_the_appointment_has_a_summary_document_activity_created
    end
  end

  scenario 'attempting to create an invalid summary document activity' do
    given_the_user_is_a_pension_wise_api_user do
      and_a_completed_appointment_exists
      when_the_client_posts_an_invalid_summary_document_request
      then_the_service_responds_with_a_422
      and_the_errors_are_serialized_in_the_response
    end
  end

  scenario 'attempting to create a summary document activity on a pending appointment' do
    given_the_user_is_a_pension_wise_api_user do
      and_a_pending_appointment_exists
      when_the_client_posts_a_valid_summary_document_request
      then_the_service_responds_with_a_422
      and_the_pending_errors_are_serialized_in_the_response
    end
  end

  def and_a_completed_appointment_exists
    @appointment = create(:appointment, status: :complete)
  end

  def and_a_pending_appointment_exists
    @appointment = create(:appointment)
  end

  def when_the_client_posts_a_valid_summary_document_request
    payload = {
      appointment_id: @appointment.id,
      owner_uid: create(:user).uid,
      delivery_method: 'postal'
    }

    post api_v1_summary_documents_path, params: payload, as: :json
  end

  def and_the_appointment_has_a_summary_document_activity_created
    expect(@appointment.activities.where(type: SummaryDocumentActivity.name).count).to eq(1)
  end

  def when_the_client_posts_an_invalid_summary_document_request
    payload = {
      appointment_id: 0,
      owner_uid: SecureRandom.uuid,
      delivery_method: ''
    }

    post api_v1_summary_documents_path, params: payload, as: :json
  end

  def then_the_service_responds_with_a_422
    expect(response).to be_unprocessable
  end

  def and_the_errors_are_serialized_in_the_response
    JSON.parse(response.body).tap do |json|
      expect(json.keys).to eq(%w(owner appointment))
    end
  end

  def and_the_pending_errors_are_serialized_in_the_response
    JSON.parse(response.body).tap do |json|
      expect(json.keys).to eq(%w(appointment))
    end
  end

  def then_the_service_responds_with_a_201
    expect(response).to be_created
  end
end
