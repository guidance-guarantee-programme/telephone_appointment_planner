require 'rails_helper'

RSpec.describe HolidayBlockSummary, '#call' do
  context 'when no holiday blocks are present' do
    it 'does not send a digest' do
      allow(Holiday).to receive(:for_email_digest).and_return([])

      subject.call

      expect(HolidayMailer).not_to receive(:block_digest)
    end
  end

  context 'when holiday blocks are present' do
    it 'sends the digest' do
      message  = double(deliver_now: true)
      holidays = [build(:holiday)]

      allow(Holiday).to receive(:for_email_digest).and_return(holidays)
      expect(HolidayMailer).to receive(:block_digest).with(holidays).and_return(message)

      subject.call
    end
  end
end
