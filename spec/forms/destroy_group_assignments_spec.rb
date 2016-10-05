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
end
