require 'rails_helper'

RSpec.describe DestroyGroupAssignments, '#call' do
  let(:group) { create(:group) }
  let(:users) { create_list(:guider, 2) }
  let(:user_ids) { users.map(&:id) }

  before do
    users.each { |u| u.groups << group }
  end

  subject { described_class.new(user_ids, group.id) }

  context 'for the given users' do
    it 'unassigns the given group' do
      expect { subject.call }.to change { GroupAssignment.count }.by(-2)
    end
  end

  context 'the group is still assigned to someone' do
    it 'does not destroy the group' do
      user = create(:user)
      user.groups << group
      expect { subject.call }.to_not change { Group.count }
    end
  end

  context 'the group is not assigned to anyone' do
    it 'destroys the group' do
      expect { subject.call }.to change { Group.count }.by(-1)
    end
  end
end
