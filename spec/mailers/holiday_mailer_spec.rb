require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe HolidayMailer, type: :mailer do
  describe 'block_digest' do
    before do
      guiders = create_list(:guider, 3)
      guiders.each do |guider|
        create(
          :holiday,
          user: guider,
          title: 'Block Booking',
          start_at: Time.zone.parse('2026-06-12 12:00'),
          end_at: Time.zone.parse('2026-06-12 13:00')
        )
      end
    end

    let(:mail) { HolidayMailer.block_digest(Holiday.for_email_digest) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Holiday Block Digest')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
    end

    it 'renders the body' do
      travel_to '2026-06-12 07:00' do
        body = mail.body.encoded
        expect(body).to match('Holiday blocks for the next 7 days')
        expect(body).to match('Block Booking')
        expect(body).to match('12:00pm, 12 June 2026 - 1:00pm, 12 June 2026')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
