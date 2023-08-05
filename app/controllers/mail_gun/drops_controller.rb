module MailGun
  class DropsController < ActionController::Base
    skip_forgery_protection

    def create
      form = DropForm.new(drop_params)
      form.create_activity

      head :ok
    end

    private

    def drop_params # rubocop:disable AbcSize, MethodLength
      event_data = params['event-data']

      description = event_data['delivery-status'][:description].presence ||
                    event_data['delivery-status'][:message].presence

      {
        event: event_data[:event],
        description: description,
        message_type: event_data['user-variables'][:message_type],
        environment: event_data['user-variables'][:environment],
        appointment_id: event_data['user-variables'][:appointment_id],
        timestamp: params[:signature][:timestamp],
        token: params[:signature][:token],
        signature: params[:signature][:signature]
      }
    end
  end
end
