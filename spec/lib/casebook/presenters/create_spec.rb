require 'rails_helper'

RSpec.describe Casebook::Presenters::Create, '#to_h' do
  let(:appointment) { build_stubbed(:appointment, :casebook_guider) }

  subject { described_class.new(appointment).to_h[:data][:attributes] }

  it 'is correctly presented' do
    expect(subject).to include(
      first_name: appointment.first_name,
      last_name: appointment.last_name,
      date_of_birth: '1945-01-01',
      mobile_phone: '07715 930 444',
      email: 'someone@example.com',
      notes: 'Pension Wise online booking. This customer is very nice.',
      user_id: appointment.guider.casebook_guider_id,
      channel: 'telephone',
      location_id: 26_089
    )
  end

  describe 'appointment start and end time' do
    context 'during BST' do
      it 'is shifted an hour to allow for timezone differences' do
        travel_to '2020-06-10 13:00' do
          expect(subject).to include(
            starts_at: '2020-06-15T11:00:00Z',
            ends_at: '2020-06-15T12:00:00Z'
          )
        end
      end
    end

    context 'during GMT' do
      it 'is not shifted' do
        travel_to '2020-11-05 13:00' do
          expect(subject).to include(
            starts_at: '2020-11-10T12:00:00Z',
            ends_at: '2020-11-10T13:00:00Z'
          )
        end
      end
    end
  end
end
