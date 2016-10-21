require 'rails_helper'

require 'gds-sso/lint/user_spec'

RSpec.describe User, type: :model do
  it_behaves_like 'a gds-sso user class'

  describe '.guiders' do
    it 'filters users by the guider permission' do
      create(:guider)
      create(:resource_manager)

      expect(described_class.guiders.all?(&:guider?)).to be_truthy
    end
  end

  describe '#guider?' do
    context 'normal user' do
      it 'is false' do
        user = build(:user)
        expect(user).to_not be_guider
      end
    end

    context 'user with guider permission' do
      it 'is true' do
        user = build(:guider)
        expect(user).to be_guider
      end
    end
  end

  describe '#resource_manager?' do
    context 'normal user' do
      it 'is false' do
        user = build(:user)
        expect(user).to_not be_resource_manager
      end
    end

    context 'user with resource_manager permission' do
      it 'is true' do
        user = build(:resource_manager)
        expect(user).to be_resource_manager
      end
    end
  end

  describe '#agent?' do
    context 'normal user' do
      it 'is false' do
        user = build(:user)
        expect(user).to_not be_agent
      end
    end

    context 'user with agent permission' do
      it 'is true' do
        user = build(:agent)
        expect(user).to be_agent
      end
    end
  end
end
