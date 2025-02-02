module SmsFailureRecordable
  extend ActiveSupport::Concern

  included do
    rescue_from(Notifications::Client::BadRequestError) do
      if (appointment = arguments[0])
        SmsFailureActivity.from(appointment)
      end
    end
  end
end
