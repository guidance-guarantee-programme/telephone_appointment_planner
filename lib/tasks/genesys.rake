require 'faye/websocket'
require 'eventmachine'

namespace :genesys do # rubocop:disable Metrics/BlockLength
  namespace :publisher do
    desc 'Pushes appointments when they have newly published/available Genesys schedules'
    task push: :environment do
      appointments = Appointment.for_genesys_newly_published_schedule

      Genesys::Services::PublishedScheduleAppointmentSynchroniser.new(appointments).call
    end
  end

  namespace :notifications do
    desc 'Subscribe and process messages for schedule updates'
    task subscribe: :environment do
      channel_data = Genesys::Api.new.notification_subscriptions

      EM.run do
        socket = Faye::WebSocket::Client.new(channel_data['connectUri'])

        socket.on(:open)    { p 'WebSocket Opened' }
        socket.on(:error)   { |event| p "WebSocket Error: #{event}" }
        socket.on(:message) do |event|
          parsed = JSON.parse(event.data)

          if parsed.dig('eventBody', 'message')&.end_with?('Heartbeat')
            socket.send('pong')
          else
            GenesysNotificationJob.perform_later(event.data)
          end
        end
        socket.on(:close) do |event|
          p "WebSocket Closed: #{event.code}, #{event.reason}"
          exit
        end
      end
    end
  end
end
