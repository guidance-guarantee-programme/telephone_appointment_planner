require 'rails_helper'
require 'timeout'

RSpec.feature 'Mailgun email verification service suggestions', js: true do
  scenario 'Mailgun says the email address is invalid' do
    given_the_user_is_an_agent do
      and_they_want_to_book_an_appointment
      with_mock_invalid_mailgun_response do
        when_they_enter_an_invalid_email_address
        and_change_focus
        then_they_should_see_be_warned_of_the_invalid_address
      end
    end
  end

  scenario 'Mailgun has a suggestion on the email address' do
    given_the_user_is_an_agent do
      and_they_want_to_book_an_appointment
      with_mock_suggested_mailgun_response do
        when_they_enter_an_email_address_with_a_suggestion
        and_change_focus
        then_they_should_see_a_correction_suggestion
      end
    end
  end

  def and_they_want_to_book_an_appointment
    @page = Pages::NewAppointment.new.tap(&:load)
  end

  def with_mock_invalid_mailgun_response(&block)
    response = {
      is_valid: false,
      address: 'something@totallyinvalid',
      parts: {
        display_name: nil,
        local_part: 'something',
        domain: 'totallyinvalid'
      },
      did_you_mean: nil
    }

    with_mock_mailgun_response(response, &block)
  end

  def with_mock_suggested_mailgun_response(&block)
    response = {
      is_valid: false,
      address: 'joe.bloggs@gmall.com',
      parts: {
        display_name: nil,
        local_part: 'joe.bloggs',
        domain: 'gmall.com'
      },
      did_you_mean: 'joe.bloggs@gmail.com'
    }

    with_mock_mailgun_response(response, &block)
  end

  def when_they_enter_an_email_address_with_a_suggestion
    @page.email.set 'joe.bloggs@gmall.com'
  end

  def when_they_enter_an_invalid_email_address
    @page.email.set 'something@totallyinvalid'
  end

  def and_change_focus
    @page.phone.click
  end

  def then_they_should_see_be_warned_of_the_invalid_address
    expect(@page).to have_content("That doesn't look like a valid address")
  end

  def then_they_should_see_a_correction_suggestion
    @page.wait_until_suggestion_visible

    expect(@page.suggestion).to have_content('joe.bloggs@gmail.com')
  end

  before(:all) do
    @server = WEBrick::HTTPServer.new(
      Port: 9293,
      StartCallback: -> { @running = true },
      Logger: Rails.logger,
      AccessLog: Rails.logger
    )

    @thread = Thread.new { @server.start }
    Timeout.timeout(1) { :wait until @running }
  end

  after(:all) do
    @server.shutdown
    @thread.kill
  end

  def with_mock_mailgun_response(response)
    @server.mount '/v2/address/validate', Rack::Handler::WEBrick, lambda { |env|
      req = Rack::Request.new(env)
      response_body = "#{req.params['callback']}(#{response.to_json})"

      [200, {}, [response_body]]
    }

    yield
  end
end
