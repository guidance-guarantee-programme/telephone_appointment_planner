require 'rails_helper'

RSpec.describe Casebook::Presenters::Cancel, '#to_h' do
  let(:appointment) { build_stubbed(:appointment, :casebook_guider) }

  subject { described_class.new(appointment).to_h[:data][:attributes] }

  it 'is correctly presented' do
    expect(subject).to eq(cancel_status: 'office_cancelled')
  end

  context 'when it was customer cancelled' do
    it 'is correctly presented' do
      %w(cancelled_by_customer cancelled_by_customer_sms).each do |status|
        appointment.status = status

        expect(subject).to eq(cancel_status: 'customer_cancelled')
      end
    end
  end
end
