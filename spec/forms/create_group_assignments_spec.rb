require 'rails_helper'

RSpec.describe CreateGroupAssignments, '#call' do
  let(:user) { create(:resource_manager) }
  let(:users) { create_list(:guider, 2) }
  let(:user_ids) { users.map(&:id) }
  let(:group_params) { Hash[name: ['Another Group']] }

  subject { described_class.new(user_ids, group_params[:name], user) }

  context 'when the users are not already members' do
    it 'assigns the group to the given users' do
      # ensure just the one group is created
      expect { subject.call }.to change { Group.count }.by(1)

      users.each do |user|
        expect(user.groups.map(&:name)).to eq(['Another Group'])
      end
    end
  end

  context 'when a user is already a member and the group exists' do
    before do
      group = create(:group, name: 'Another Group')

      users.first.group_assignments.create(group:)
    end

    it 'only assigns to the other user' do
      expect { subject.call }.to change { GroupAssignment.count }.by(1)
    end
  end
end
