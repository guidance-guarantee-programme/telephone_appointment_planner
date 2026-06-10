require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Genesys::Schedule, '#published_schedule_uri' do
  let(:response) do
    double(
      parsed: {
        'result' => {
          'publishedSchedules' => [
            {
              'weekDate' => '2026-01-01',
              'selfUri' => '/nice/1/son'
            }
          ]
        }
      }
    )
  end

  subject { described_class.new(response, appointment) }

  context 'when no match could be found' do
    let(:appointment) { double(week_date: '2025-01-01', id: 123) }

    it 'raises an error' do
      expect { subject.published_schedule_uri }.to raise_error(RuntimeError)
    end
  end

  context 'when a match is found' do
    let(:appointment) { double(week_date: '2026-01-01', id: 123) }

    it 'returns the `selfUri`' do
      expect(subject.published_schedule_uri).to eq('/nice/1/son')
    end
  end
end
# rubocop:enable Metrics/BlockLength
