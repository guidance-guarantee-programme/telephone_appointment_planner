module Genesys
  module Models
    class Activity
      attr_reader :start_date, :length_minutes, :description, :activity_code_id, :paid

      def initialize(activity_hash)
        @activity_hash = activity_hash
        @start_date = activity_hash['startDate']
        @start_date = Time.zone.parse(@start_date) if @start_date.is_a?(String)
        @length_minutes = activity_hash['lengthMinutes']
        @description = activity_hash['description']
        @activity_code_id = activity_hash['activityCodeId']
        @paid = activity_hash['paid']
      end

      def to_h
        {
          'startDate' => start_date.iso8601,
          'lengthMinutes' => length_minutes,
          'description' => description,
          'activityCodeId' => activity_code_id,
          'paid' => paid
        }
      end

      def date_range
        start_date..end_date
      end

      def end_date
        start_date + length_minutes.minutes
      end

      def overlaps?(activity)
        date_range.overlap?(activity.date_range)
      end

      def self.from_appointment(appointment, rescheduling: false)
        args = {
          'startDate' => appointment.start_at,
          'lengthMinutes' => 70,
          'description' => appointment.id.to_s,
          'activityCodeId' => rescheduling ? '0' : appointment.genesys_activity_code_id,
          'paid' => true
        }

        new(args)
      end

      def self.from_gap_between(left, right)
        args = {
          'startDate' => left.end_date,
          'lengthMinutes' => (right.start_date - left.end_date) / 60,
          'activityCodeId' => '0',
          'description' => 'Filler'
        }

        new(args)
      end

      def self.from(start_date, end_date)
        args = {
          'startDate' => start_date,
          'lengthMinutes' => (end_date - start_date) / 60,
          'activityCodeId' => '0',
          'description' => 'Filler'
        }

        new(args)
      end
    end
  end
end
