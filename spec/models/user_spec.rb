require 'rails_helper'

require 'gds-sso/lint/user_spec'

RSpec.describe User, type: :model do
  it_behaves_like 'a gds-sso user class'

  describe '#guider?' do
    context 'normal user' do
      it 'is false' do
        user = build(:user)
        expect(user).to_not be_guider
      end
    end

    context 'user with guider permission' do
      it 'is true' do
        user = build(:guider_user)
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
        user = build(:resource_manager_user)
        expect(user).to be_resource_manager
      end
    end
  end
end
