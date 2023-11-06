require 'rails_helper'

require 'gds-sso/lint/user_spec'

# rubocop:disable Metrics/BlockLength
RSpec.describe User, type: :model do
  it_behaves_like 'a gds-sso user class'

  describe '#schedule_type' do
    it 'defaults to pension_wise' do
      guider = build(:guider)

      expect(guider.schedule_type).to eq(User::PENSION_WISE_SCHEDULE_TYPE)
    end
  end

  describe '#organisation' do
    it 'returns the correct descriptive text based on organisation membership' do
      tp   = build_stubbed(:guider, :tp)
      tpas = build_stubbed(:guider)
      cas  = build_stubbed(:guider, :cas)

      expect(tp.organisation).to eq('TP')
      expect(tpas.organisation).to eq('TPAS')
      expect(cas.organisation).to eq('CAS')
    end
  end

  describe '#colleagues' do
    it 'returns users in the same organisation' do
      guider      = create(:guider, :tp)
      tpas_guider = create(:guider)

      # includes itself
      expect(guider.colleagues).to match_array(guider)
      # does not include the TP guider
      expect(tpas_guider.colleagues).to_not match_array(guider)
    end
  end

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

  describe '#contact_centre_team_leader?' do
    it 'is true' do
      expect(build_stubbed(:contact_centre_team_leader)).to be_contact_centre_team_leader
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

  describe '#bookable_slots' do
    it 'destroys them when the user is destroyed' do
      guider = create(:guider)
      create(:bookable_slot, guider: guider)
      create(:bookable_slot, guider: guider)
      expect { guider.destroy }.to change { BookableSlot.count }.by(-2)
    end
  end
end
# rubocop:enable Metrics/BlockLength
