require 'rails_helper'

RSpec.describe CustomerUpdateJob, '#perform' do
  include ActiveJob::TestHelper

  it 'guards against no customer email' do
    appointment = double(email?: false)

    described_class.new.perform(appointment, 'message')

    assert_no_enqueued_jobs
    expect(CustomerUpdateActivity.count).to be_zero
  end
end
