class GenesysJob < ApplicationJob
  queue_as :single

  discard_on(Genesys::PublishedScheduleMissingError) do |_, error|
    Bugsnag.notify(error)
  end
end
