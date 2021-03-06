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
end
