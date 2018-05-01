require 'rails_helper'

RSpec.describe SmsCancellationActivity do
  let(:appointment) { create(:appointment) }

  subject { described_class.from(appointment) }

  it 'notifies the owning guider' do
    expect(subject.pusher_notify_user_ids).to eq(appointment.guider_id)
  end
end
