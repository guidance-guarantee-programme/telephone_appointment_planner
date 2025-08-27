require 'faye/websocket'
require 'eventmachine'

namespace :genesys do
  namespace :notifications do
    desc 'Subscribe and process messages for schedule updates'
    task subscribe: :environment do
      channel_data = Genesys::Api.new.notification_subscriptions

      EM.run do
        socket = Faye::WebSocket::Client.new(channel_data['connectUri'])

        socket.on(:open)    { p 'WebSocket Opened' }
        socket.on(:error)   { |event| p "WebSocket Error: #{event}" }
        socket.on(:message) { |event| GenesysNotificationJob.perform_later(event.data) }
        socket.on(:close)   { |event| p "WebSocket Closed: #{event.code}, #{event.reason}" }
      end
    end
  end
end
