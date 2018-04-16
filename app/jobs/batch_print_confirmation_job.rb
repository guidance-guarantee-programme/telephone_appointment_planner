class BatchPrintConfirmationJob < ApplicationJob
  queue_as :default

  def perform
    BatchPrintConfirmation.new.call
  end
end
