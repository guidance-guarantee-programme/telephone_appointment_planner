require 'rails_helper'

RSpec.describe BatchPrintCsv do
  before do
    travel_to '2018-03-22 12:00'
  end

  after do
    travel_back
  end

  it 'presents the header and rows correctly' do
    @appointment = create(
      :appointment,
      :with_address,
      id: 9999,
      first_name: 'George',
      last_name: 'Daisy'
    )

    expect(subject.call(@appointment)).to eq(<<~CSV)
      Date,Reference,Appointment date,Appointment time,First name,Last name,Address line one,Address line two,Address line three,Town,County,Postcode,Letter type,Phone,Memorable word
      22 March 2018,9999,27 March 2018,12:00pm BST,George,Daisy,10 Some Road,Some Street,Somewhere,Some Town,Some County,E3 3NN,Booking,0208 252 4758,l*****e
    CSV
  end
end
