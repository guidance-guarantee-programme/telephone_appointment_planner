module Genesys
  module Models
    class Shift
      attr_reader :id, :start_date, :length_minutes, :manually_edited

      alias manually_edited? manually_edited

      def initialize(shift_hash)
        @id = shift_hash['id']
        @start_date = Time.zone.parse(shift_hash['startDate'])
        @length_minutes = shift_hash['lengthMinutes']
        @manually_edited = shift_hash['manuallyEdited']
        @activities = shift_hash['activities'].map { |activity_hash| Activity.new(activity_hash) }
      end

      def to_h
        {
          'id' => id,
          'startDate' => start_date.iso8601,
          'lengthMinutes' => length_minutes,
          'manuallyEdited' => manually_edited,
          'activities' => activities.map(&:to_h)
        }
      end

      def activities
        @activities.sort_by(&:start_date)
      end

      def end_date
        start_date + length_minutes.minutes
      end

      def covers?(activity)
        (start_date..end_date).cover?(activity.start_date)
      end

      def overlapping_activities(activity)
        activities.select { |a| a.overlaps?(activity) }
      end

      def create_activity(activity)
        return unless covers?(activity)

        @manually_edited = true

        @activities -= overlapping_activities(activity)
        @activities << activity

        fill_scheduling_gaps

        @activities
      end

      def fill_scheduling_gaps
        fillers = []

        activities.each_cons(2) do |left, right|
          next if left.end_date == right.start_date

          fillers << Activity.from_gap_between(left, right)
        end

        fillers.each { |filler| @activities << filler }

        fill_start_and_end_of_shift
      end

      private

      def fill_start_and_end_of_shift
        @activities << Activity.from(start_date, activities.first.start_date) unless start_aligns?
        @activities << Activity.from(activities.last.end_date, end_date)      unless end_aligns?
      end

      def start_aligns?
        start_date == activities.first.start_date
      end

      def end_aligns?
        end_date == activities.last.end_date
      end
    end
  end
end
