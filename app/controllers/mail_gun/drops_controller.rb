module MailGun
  class DropsController < ActionController::Base
    skip_forgery_protection

    def create
      form = DropForm.new(drop_params)
      form.create_activity

      head :ok
    end

    private

    def drop_params
      params.permit(
        :event,
        :description,
        :appointment_id,
        :message_type,
        :environment,
        :timestamp,
        :token,
        :signature
      )
    end
  end
end
