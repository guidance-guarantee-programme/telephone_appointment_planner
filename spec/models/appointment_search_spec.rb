require 'rails_helper'

RSpec.describe AppointmentSearch, type: :model do
  describe '#search' do
    before do
      from = BusinessDays.from_now(3).at_midday

      @appointments = [
        create(:appointment, first_name: 'Stefan', last_name: 'Löfven', created_at: from + 2.seconds),
        create(:appointment, first_name: 'Angela', last_name: 'Merkel', created_at: from + 1.second),
        create(:appointment, first_name: 'Adrian', last_name: 'Hasler', created_at: from)
      ]
    end

    def results(q, start_at, end_at, current_user = create(:agent))
      described_class.new(q, start_at, end_at, current_user).search
    end

    it 'returns all results' do
      expect(results(nil, nil, nil)).to eq @appointments
    end

    it 'returns results for appointment ID' do
      results = results(@appointments.second.id.to_s, nil, nil)
      expect(results).to eq [@appointments.second]
    end

    it 'returns results for customer first_name' do
      results = results(@appointments.third.first_name.downcase, nil, nil)
      expect(results).to eq [@appointments.third]
    end

    it 'returns results for customer last_name' do
      results = results(@appointments.second.last_name.downcase, nil, nil)
      expect(results).to eq [@appointments.second]
    end

    it 'returns matches for prefixes' do
      results = results(@appointments.first.last_name[0..3], nil, nil)
      expect(results).to eq [@appointments.first]
    end

    it 'returns matches for multiple words' do
      results = results("#{@appointments.first.first_name} #{@appointments.first.last_name}", nil, nil)
      expect(results).to eq [@appointments.first]
    end

    it 'returns results for a date range' do
      date_range_start = 30.days.from_now.to_date
      date_range_end = 40.days.from_now.to_date
      start_at = date_range_start + 5.hours
      end_at = start_at + 1.hour
      appointment = create(:appointment, start_at: start_at, end_at: end_at)
      results = results(nil, date_range_start, date_range_end)
      expect(results).to eq [appointment]
    end

    it 'returns results for guider name' do
      guider = create(:guider, name: 'Kate Bush')
      appointment = @appointments.first
      appointment.guider = guider
      appointment.save!
      results = results('kate bush', nil, nil)
      expect(results).to eq [appointment]
    end
  end
end
