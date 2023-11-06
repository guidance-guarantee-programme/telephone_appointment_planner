module MailGun
  class DropsController < ActionController::Base
    skip_forgery_protection

    def create
      form = DropForm.new(drop_params)
      form.create_activity

      head :ok
    end

    private

    def drop_params # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      event_data = params['event-data']

      description = event_data.dig('delivery-status', :description).presence ||
                    event_data.dig('delivery-status', :message).presence

      {
        event: event_data[:event],
        description: description,
        message_type: event_data.dig('user-variables', :message_type),
        environment: event_data.dig('user-variables', :environment),
        appointment_id: event_data.dig('user-variables', :appointment_id),
        timestamp: params[:signature][:timestamp],
        token: params[:signature][:token],
        signature: params[:signature][:signature]
      }
    end
  end
end
