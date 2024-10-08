require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AppointmentSearch, type: :model do
  describe '#search' do
    before do
      from = BusinessDays.from_now(3).at_midday

      @appointments = [
        create(:appointment, first_name: 'Stefan', last_name: 'Löfven', created_at: from + 2.seconds),
        create(:appointment, first_name: 'Angela', last_name: 'Merkel', created_at: from + 1.second),
        create(:appointment, first_name: 'Adrian', last_name: 'Hasler', created_at: from, processed_at: Time.current)
      ]
    end

    # rubocop:disable Metrics/ParameterLists
    def results(
      query,
      start_at,
      end_at,
      current_user = create(:agent),
      processed = '',
      appointment_type = ''
    )
      described_class.new(query, start_at, end_at, current_user, processed, appointment_type).search
    end
    # rubocop:enable Metrics/ParameterLists

    it 'filters by type' do
      @appointments.map(&:destroy)

      pw = create(:appointment)
      dd = create(:appointment, :due_diligence)
      user = create(:resource_manager)

      expect(results(nil, nil, nil, user, '', '')).to eq([dd, pw])
      expect(results(nil, nil, nil, user, '', 'pension_wise')).to eq([pw])
      expect(results(nil, nil, nil, user, '', 'due_diligence')).to eq([dd])
    end

    context 'for a TPAS guider and resource manager' do
      it 'returns all organisation’s appointments' do
        north_tyneside = create(:appointment, organisation: :north_tyneside)
        guider = build(:guider, :tpas)

        expect(results(nil, nil, nil, guider, '', '')).to include(north_tyneside)
      end
    end

    context 'for a non-tpas user' do
      it 'respects the `processed` flag' do
        processed   = create(:appointment, organisation: :cas, processed_at: Time.current)
        unprocessed = create(:appointment, organisation: :cas)
        cas_agent   = create(:agent, :cas)

        expect(results(nil, nil, nil, cas_agent, 'yes')).to eq([processed])
        expect(results(nil, nil, nil, cas_agent, 'no')).to eq([unprocessed])

        # always return the only result by ID whether processed
        expect(results(processed.to_param, nil, nil, cas_agent, 'no')).to eq([processed])
        expect(results(processed.to_param, nil, nil, cas_agent, 'yes')).to eq([processed])
      end
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
      appointment = create(:appointment, start_at:, end_at:)
      results = results(nil, date_range_start, date_range_end)
      expect(results).to eq [appointment]
    end
  end
end
# rubocop:enable Metrics/BlockLength
