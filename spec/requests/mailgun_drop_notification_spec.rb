require 'rails_helper'

RSpec.describe 'POST /mail_gun/drops' do
  scenario 'inbound hooks create activity entries' do
    with_a_configured_token('deadbeef') do
      given_an_appointment
      when_mail_gun_posts_a_drop_notification
      then_an_activity_is_created
      and_the_service_responds_ok
    end
  end

  def with_a_configured_token(token)
    existing = ENV['MAILGUN_API_TOKEN']

    ENV['MAILGUN_API_TOKEN'] = token
    yield
  ensure
    ENV['MAILGUN_API_TOKEN'] = existing
  end

  def given_an_appointment
    @appointment = create(:appointment)
  end

  def when_mail_gun_posts_a_drop_notification
    payload = {
      "signature": {
        "token": 'secret',
        "timestamp": '1474638633',
        "signature": 'abf02bef01e803bea52213cb092a31dc2174f63bcc2382ba25732f4c84e084c1'
      },
      "event-data": {
        "event": 'dropped',
        "delivery-status": {
          "description": 'the reasoning'
        },
        "user-variables": {
          "message_type": 'booking_created',
          "environment": 'production',
          "appointment_id": @appointment.to_param
        }
      }
    }

    post mail_gun_drops_path, params: payload, as: :json
  end

  def then_an_activity_is_created
    expect(DropActivity.last.appointment).to eq(@appointment)
  end

  def and_the_service_responds_ok
    expect(response).to be_successful
  end
end
