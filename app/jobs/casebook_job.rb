class CasebookJob < ApplicationJob
  discard_on Casebook::ApiError do |_, error|
    Bugsnag.notify(error)
  end

  retry_on Faraday::TimeoutError, wait: :exponentially_longer

  queue_as :default
end
