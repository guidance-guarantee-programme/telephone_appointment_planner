require 'rails_helper'

RSpec.feature 'Pension Wise imports historical data' do
  scenario 'All records import successfully' do
    given_a_valid_csv_to_import
    when_the_csv_is_imported
    the_appointments_are_imported_successfully
    and_no_activities_are_created
  end

  def given_a_valid_csv_to_import
    file = File.expand_path('../../spec/support/fixtures/good_data.csv', __dir__)

    @csv = IO.read(file)
  end

  def when_the_csv_is_imported
    CsvImporter.new(@csv).call
  end

  def the_appointments_are_imported_successfully
    expect(Appointment.count).to eq(1)

    Appointment.first.tap do |appointment|
      expect(appointment.agent.name).to  eq('Pension Wise Importer')
      expect(appointment.guider.name).to eq('Waheeda Noormohamed')

      expect(appointment).to have_attributes(
        id: 1229,
        start_at: Time.zone.parse('2015-04-06 14:50:00 UTC'),
        end_at: Time.zone.parse('2015-04-06 16:00:00 UTC'),
        first_name: 'George',
        last_name: 'Smith',
        email: 'customer@email.com',
        phone: '0208 252 4729',
        mobile: '07715 930 459',
        date_of_birth: Date.parse('1950-01-01'),
        memorable_word: 'Memorable Word',
        status: 'complete',
        notes: 'This was good.',
        opt_out_of_market_research: true
      )
    end
  end

  def and_no_activities_are_created
    expect(Appointment.first.activities).to be_empty
  end
end
