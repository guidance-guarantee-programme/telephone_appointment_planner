require 'oauth2'

module Genesys
  class Api
    def initialize(client: nil)
      @client = client
    end

    def push(appointment, rescheduling: false) # rubocop:disable Metrics/MethodLength
      appointment      = Genesys::Presenters::Appointment.new(appointment, rescheduling:)
      schedule         = find_schedule(appointment)
      schedule_version = find_schedule_version(schedule)
      agent_schedule   = find_agent_schedule(schedule, appointment)
      activity         = Genesys::Models::Activity.from_appointment(appointment, rescheduling:)

      agent_schedule.assign_activity(activity)

      upload_details   = signed_upload(schedule)
      schedule_payload = Genesys::Presenters::Schedule.new(schedule_version, agent_schedule).to_h

      perform_upload(upload_details, schedule_payload)
      operation_response = process_upload(schedule, upload_details)

      operation_response['operationId']
    end

    def notification_subscriptions # rubocop:disable Metrics/MethodLength
      topics = [
        {
          'id' => 'v2.workforcemanagement.businessunits.71876e55-8410-4ac4-b675-ec6724cde3ec.schedules',
          'state' => 'Permitted'
        }
      ]

      channel = token.post('/api/v2/notifications/channels', headers: { 'Content-Type' => 'application/json' }).parsed

      token.put(
        "/api/v2/notifications/channels/#{channel['id']}/subscriptions",
        body: topics.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      channel
    end

    private

    def find_schedule(appointment)
      path = '/api/v2/workforcemanagement/managementunits/' \
        "#{appointment.guider.genesys_management_unit_id}/agentschedules/search"

      payload = {
        'startDate' => appointment.start_at.beginning_of_month.iso8601,
        'endDate' => appointment.start_at.end_of_month.iso8601,
        'userIds' => Array(appointment.guider.genesys_agent_id)
      }

      response = token.post(path, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })

      Schedule.new(response)
    end

    def find_schedule_version(schedule)
      response = token.get(schedule.published_schedule_uri, headers: { 'Content-Type' => 'application/json' })

      FullSchedule.new(response)
    end

    def find_agent_schedule(schedule, appointment)
      path = schedule.published_schedule_uri.dup.concat('/agentschedules/query')

      payload = {
        'managementUnitId' => appointment.guider.genesys_management_unit_id,
        'userIds' => Array(appointment.guider.genesys_agent_id)
      }

      response = token.post(path, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })

      Genesys::Models::AgentSchedule.new(response.parsed['result']['agentSchedules'].first)
    end

    def signed_upload(schedule)
      path = schedule.published_schedule_uri.dup.concat('/update/uploadurl')
      payload = { 'contentLengthBytes' => 2048 }

      response = token.post(path, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })

      Upload.new(response)
    end

    def process_upload(schedule, upload_details)
      path = schedule.published_schedule_uri.dup.concat('/update')
      payload = { 'uploadKey' => upload_details.upload_key }

      response = token.post(path, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
      response.parsed
    end

    def perform_upload(upload_details, schedule_payload)
      gzipped_payload = ActiveSupport::Gzip.compress(schedule_payload.to_json)

      client.request(:put, upload_details.url, body: gzipped_payload, headers: upload_details.headers)
    end

    def token
      @token ||= client.client_credentials.get_token(scope: 'workforce-management')
    end

    def client
      @client ||= OAuth2::Client.new(client_id, client_secret, site:, token_url:, auth_scheme: :basic_auth)
    end

    def site
      ENV['GENESYS_SITE']
    end

    def client_id
      ENV['GENESYS_CLIENT_ID']
    end

    def client_secret
      ENV['GENESYS_CLIENT_SECRET']
    end

    def token_url
      ENV['GENESYS_TOKEN_URL']
    end
  end
end
