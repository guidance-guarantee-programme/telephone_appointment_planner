require 'rails_helper'

RSpec.describe AppointmentAttempt, type: :model do
  describe 'validations' do
    let(:subject) do
      build_stubbed(:appointment_attempt)
    end

    it 'is valid with valid parameters' do
      expect(subject).to be_valid
    end

    required = [
      :first_name,
      :last_name,
      :date_of_birth
    ]
    required.each do |field|
      it "validate presence of #{field}" do
        subject.public_send("#{field}=", nil)
        subject.validate
        expect(subject.errors[field]).to_not be_empty
      end
    end
  end

  describe '#eligible?' do
    context 'customers that are 50 or older' do
      before { subject.date_of_birth = 60.years.ago }

      context 'that have a defined contribution pot' do
        before { subject.defined_contribution_pot = true }

        it 'is true' do
          expect(subject).to be_eligible
        end
      end
      context 'that do not have a defined contribution pot' do
        before { subject.defined_contribution_pot = false }

        it 'is false' do
          expect(subject).to_not be_eligible
        end
      end
    end

    context 'customers that are younger than 50' do
      before { subject.date_of_birth = 10.years.ago }

      context 'that have a defined contribution pot' do
        before { subject.defined_contribution_pot = true }

        it 'is false' do
          expect(subject).to_not be_eligible
        end
      end
      context 'that do not have a defined contribution pot' do
        before { subject.defined_contribution_pot = false }

        it 'is false' do
          expect(subject).to_not be_eligible
        end
      end
    end
  end
end
