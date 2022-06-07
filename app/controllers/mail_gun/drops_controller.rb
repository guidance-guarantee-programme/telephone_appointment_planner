module MailGun
  class DropsController < ActionController::Base
    skip_forgery_protection

    def create
      form = DropForm.new(drop_params)
      form.create_activity

      log_btinternet_drops

      head :ok
    end

    private

    def log_btinternet_drops
      return unless drop_params[:description].include? 'btinternet'

      Rails.logger.info 'Mail drop for @btinternet'
    end

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
