require 'rails_helper'

RSpec.describe SummaryDocumentLink do
  subject { described_class.query(build(:appointment, :with_address)) }

  it 'includes the telephone appointment flag' do
    expect(subject).to include('%5Btelephone_appointment%5D=true')
  end

  it 'includes encoded address elements' do
    expect(subject).to include(
      '10+Some+Road',
      'Some+Street',
      'Somewhere',
      'Some+Town',
      'Some+County',
      'E3+3NN',
      'United+Kingdom'
    )
  end

  it 'includes the schedule type' do
    expect(subject).to include('%5Bschedule_type%5D=pension_wise')
  end

  it 'includes the unique reference number' do
    expect(subject).to include('%5Bunique_reference_number%5D=')
  end
end
