class GenesysJob < ApplicationJob
  queue_as :single

  discard_on(Genesys::PublishedScheduleMissingError, Genesys::ActivityUnassignableError) do |_, error|
    Bugsnag.notify(error)
  end
end
