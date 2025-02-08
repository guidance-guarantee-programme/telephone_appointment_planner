module SmsFailureRecordable
  extend ActiveSupport::Concern

  included do
    rescue_from(Notifications::Client::BadRequestError) do
      if (appointment = arguments[0])
        SmsFailureActivity.from(appointment)

        SmsFailureNotificationsJob.perform_later(appointment)
      end
    end
  end
end
