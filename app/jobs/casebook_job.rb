class CasebookJob < ApplicationJob
  discard_on Casebook::ApiError do |_, error|
    Bugsnag.notify(error)
  end

  queue_as :default
end
