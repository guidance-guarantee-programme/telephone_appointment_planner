class BslCustomerExitPollJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    AppointmentMailer.bsl_customer_exit_poll(appointment)

    BslCustomerExitPollActivity.from(appointment)
  end
end
