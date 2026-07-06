module Genesys
  module Services
    class PublishedScheduleAppointmentSynchroniser
      def initialize(appointments)
        @appointments = appointments
      end

      def call
        appointments.each do |appointment|
          Genesys::Push.new(appointment).call
        rescue Genesys::PublishedScheduleMissingError, Genesys::ActivityUnassignableError => e
          Bugsnag.notify(e)
        end
      end

      private

      attr_reader :appointments
    end
  end
end
