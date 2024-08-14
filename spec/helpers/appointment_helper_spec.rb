require 'rails_helper'

describe AppointmentHelper do
  describe '#rebooked_from_heading' do
    context 'when not rebooked' do
      it 'returns empty' do
        appointment = build_stubbed(:appointment)

        expect(helper.rebooked_from_heading(appointment)).to be_nil
      end
    end

    context 'when rebooked' do
      context 'online' do
        it 'displays the `online` part' do
          appointment = build_stubbed(
            :appointment,
            rebooked_from: build_stubbed(
              :appointment,
              id: 123_456,
              status: :cancelled_by_customer_online
            )
          )

          expect(helper.rebooked_from_heading(appointment)).to match(/Rebooked online from #123456/)
        end
      end

      context 'normally' do
        it 'does not display the `online` part' do
          appointment = build_stubbed(
            :appointment,
            rebooked_from: build_stubbed(
              :appointment,
              id: 123_456
            )
          )

          expect(helper.rebooked_from_heading(appointment)).to match(/Rebooked from #123456/)
        end
      end
    end
  end
end
