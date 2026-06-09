module Genesys
  module Models
    class AgentSchedule
      attr_reader :user, :shifts, :metadata

      def initialize(agent_schedule_hash)
        @user = User.new(agent_schedule_hash['user'])
        @shifts = agent_schedule_hash['shifts'].map { |shift_hash| Shift.new(shift_hash) }
        @metadata = Metadata.new(agent_schedule_hash['metadata'])
      end

      def to_h
        {
          'manuallyEdited' => true,
          'shifts' => shifts.select(&:manually_edited).map(&:to_h),
          'metadata' => metadata.to_h
        }.merge(user.to_h)
      end

      def assign_activity(activity)
        shift = shifts.find { |s| s.covers?(activity) }

        return unless shift

        shift.create_activity(activity)
      end
    end
  end
end
