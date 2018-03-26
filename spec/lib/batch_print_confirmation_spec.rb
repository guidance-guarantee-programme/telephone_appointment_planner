require 'rails_helper'

RSpec.describe BatchPrintConfirmation do
  let(:ftp) { double(BatchPrintFtp, call: true) }
  let(:csv_generator) { double(BatchPrintCsv, call: 'CSV data') }

  subject { described_class.new(ftp: ftp, csv_generator: csv_generator) }

  context 'when print confirmations are ready to be exported' do
    it 'exports and marks appointments as batch processed' do
      @confirmation = create(:appointment, :with_address)

      expect { subject.call }.to change { PrintBatchActivity.count }.by(1)

      expect(@confirmation.reload).to be_batch_processed_at
    end
  end
end
