require 'rails_helper'

RSpec.describe Redactor do
  describe '.redact_for_gdpr' do
    it 'redacts records yet to be redacted, greater than 2 years old' do
      travel_to '2018-02-28 10:00' do
        @redacted = create(:appointment, first_name: 'redacted', created_at: Time.current)
        @included = create(:appointment, created_at: Time.current)
      end

      travel_to '2020-01-01 10:00' do
        @excluded = create(:appointment, created_at: Time.current)
      end

      travel_to '2020-03-31 10:00' do
        described_class.redact_for_gdpr
      end

      # was redacted
      expect(@included.reload.created_at).not_to eq(@included.updated_at)
      # was already redacted so not updated
      expect(@redacted.reload.created_at).to eq(@redacted.updated_at)
      # was outside the date range so not updated
      expect(@excluded.reload.created_at).to eq(@excluded.updated_at)
    end
  end

  describe '#call' do
    it 'redacts all personally identifying information' do
      appointment = create(:appointment)
      redactor    = described_class.new(appointment.id)

      redactor.call

      expect(appointment.reload).to have_attributes(
        first_name: 'redacted',
        last_name: 'redacted',
        email: 'redacted@example.com',
        phone: '00000000000',
        mobile: '00000000000',
        date_of_birth: '1950-01-01'.to_date,
        memorable_word: 'redacted',
        address_line_one: 'redacted',
        address_line_two: 'redacted',
        address_line_three: 'redacted',
        town: 'redacted',
        postcode: 'redacted',
        notes: 'redacted'
      )

      expect(appointment.audits).to be_empty
      # all activities except `AssignmentActivity` will be redacted
      expect(appointment.activities.map(&:class).map(&:name)).to eq(%w[AssignmentActivity CreateActivity])
    end
  end
end
