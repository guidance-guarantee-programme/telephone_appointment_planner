require 'rails_helper'

RSpec.describe SummaryDocumentLink do
  it 'includes encoded address elements' do
    @query = described_class.query(build(:appointment, :with_address))

    expect(@query).to include(
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
