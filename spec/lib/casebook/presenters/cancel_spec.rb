require 'rails_helper'

RSpec.describe Casebook::Presenters::Cancel, '#to_h' do
  let(:appointment) { build_stubbed(:appointment, :casebook_guider) }

  subject { described_class.new(appointment).to_h[:data][:attributes] }

  context 'when rescheduling' do
    let(:appointment) { build_stubbed(:appointment, :casebook_guider, :pension_wise_rescheduled) }

    it 'provides the rescheduling reason' do
      expect(subject).to eq(cancel_status: 'office_rescheduled')
    end
  end

  context 'when cancelling as usual' do
    it 'is correctly presented' do
      expect(subject).to eq(cancel_status: 'office_cancelled')
    end

    context 'when it was customer cancelled' do
      it 'is correctly presented' do
        %w[cancelled_by_customer cancelled_by_customer_sms].each do |status|
          appointment.status = status

          expect(subject).to eq(cancel_status: 'customer_cancelled')
        end
      end
    end
  end
end
