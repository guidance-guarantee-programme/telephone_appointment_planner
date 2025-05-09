class CasebookJob < ApplicationJob
  retry_on Faraday::TimeoutError, wait: :exponentially_longer
  retry_on Casebook::ApiError, wait: 3.seconds, attempts: 5

  queue_as :default
end
